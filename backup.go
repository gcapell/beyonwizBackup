// backup copies/transcodes everything from the Beyonwiz to some local drive.

package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"regexp"
	"strings"
	"time"
)

const dstBase = "/f/video/beyonwiz"

type DB interface {
	has(string) bool
	add(string) error
	close() error
}

type transcodeJob struct {
	src, dst, track string
}

func main() {
	db, err := loadDB()
	if err != nil {
		log.Fatal(err)
	}
	defer db.close()

	ch := make(chan transcodeJob, 1)
	go fetchStuff(ch, db)

	for j := range ch {
		if err := sh("HandBrakeCLI", "-i", j.src, "-o", j.dst, "-e", "x264"); err != nil {
			log.Fatal(err)
		}
		if err := os.Remove(j.src); err != nil {
			log.Fatal(err)
		}
		if err := os.Remove(path.Dir(j.src)); err != nil {
			log.Fatal(err)
		}
		if err := db.add(j.track); err != nil {
			log.Fatal(err)
		}
	}
	log.Println("all done")
}

func fetchStuff(ch chan transcodeJob, db DB) {
	index, err := loadIndex()
	if err != nil {
		log.Fatal(err)
	}
	for _, track := range index {
		if db.has(track) {
			log.Printf("skipping %s", track)
			continue
		}
		tmpDir, err := ioutil.TempDir("", "beyonwizBackup")
		if err != nil {
			log.Fatal(err)
		}
		subDir, name := convertTrackName(track)
		if err := sh("getWizPnP.pl", "--ts",
			"--recursive", "-v", "-B",
			track, "--outDir", tmpDir); err != nil {
			log.Fatal(err)
		}
		src, err := findFile(tmpDir)
		if err != nil {
			log.Fatal(err)
		}
		dstDir := path.Join(dstBase, subDir)
		if err := os.MkdirAll(dstDir, 0755); err != nil {
			log.Fatal(err)
		}
		transcodeDst := path.Join(dstDir, name)
		ch <- transcodeJob{src, transcodeDst, track}
	}
	close(ch)
}

var trackRE = regexp.MustCompile("recordings/(.*)/[^/]+")

func convertTrackName(track string) (string, string) {
	if !strings.HasPrefix(track, "recordings/") {
		log.Fatalf("bad track %q", track)
	}
	dir, name := path.Split(track[len("recordings/"):])
	spacePos := strings.LastIndex(name, " ")
	if spacePos == -1 {
		log.Fatalf("no space in %q", name)
	}
	title, date := name[:spacePos], name[spacePos+1:]
	t, err := time.Parse("Jan.2.2006_15.4", date)
	if err != nil {
		log.Fatalf("%s parsing %q", err, date)
	}
	name = t.Format("2006-01-02_15:04_") + title + ".mp4"
	return dir, name
}

func findFile(d string) (string, error) {
	f, err := os.Open(d)
	if err != nil {
		return "", err
	}
	names, err := f.Readdirnames(3)
	if err != nil {
		return "", fmt.Errorf("%s from Readdirnames(%s)", err, d)
	}
	if len(names) != 1 {
		return "", fmt.Errorf("Expected one file in %s, got %s", d, names)
	}
	return path.Join(d, names[0]), nil
}

func loadIndex() ([]string, error) {
	nameRE := regexp.MustCompile("Index name: (.*)\n")
	contents, err := ioutil.ReadFile("all.txt")
	if err != nil {
		return nil, err
	}
	matches := nameRE.FindAllSubmatch(contents, -1)
	var reply []string
	for _, match := range matches {
		reply = append(reply, string(match[1]))
	}

	return reply, nil
}

type simpleDB struct {
	got map[string]bool
	f   *os.File
}

func (s simpleDB) has(k string) bool {
	return s.got[k]
}

func (s simpleDB) add(k string) error {
	s.f.Write([]byte(k + "\n"))
	s.f.Sync()
	return nil
}

func (s simpleDB) close() error {
	return s.f.Close()
}

func loadDB() (DB, error) {
	f, err := os.OpenFile("db.txt", os.O_RDWR|os.O_APPEND, 0644)
	if err != nil {
		return nil, err
	}
	s := bufio.NewScanner(f)
	got := make(map[string]bool)
	for s.Scan() {
		got[s.Text()] = true
	}
	if err := s.Err(); err != nil {
		return nil, err
	}
	return simpleDB{got, f}, nil
}

func sh(args ...string) error {
	p, err := exec.LookPath(args[0])
	if err != nil {
		return err
	}
	cmd := exec.Command(p, args[1:]...)
	log.Println("exec", cmd.Args)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
