package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"time"
	"log"
)

type Word uint16
type LongWord uint32
type ByteBool uint8

type FileHeader struct {
	Header, Ver, VidPid, AudPid, PcrPid, PmtPid Word
	Lock, Full, Inrec ByteBool
}

type Offset struct {
	LastOff uint64
	FileOff [200] uint64 // 8640
}

func (o Offset)String()string{
	return fmt.Sprintf("Off Last:%x, FileOff%x", o.LastOff, o.FileOff)
}

type TSPoint struct {
	Svc [256]byte
	Evt [256]byte
	
	MJD Word
	Start LongWord
	Last, Sec Word
	_ LongWord
	Offset Offset
}
var mjdEpoch = time.Date(1858, 11,17,0,0,0,0, time.UTC)
func mjd(n int) time.Time {
	return mjdEpoch.AddDate(0,0,n)
}

func (t TSPoint) String() string {
	return fmt.Sprintf("Svc: %s, Evt: %s, MJD %s, Start %x, Last %d, Sec %d, Offset  %s",
		string(t.Svc[:]), string(t.Evt[:]), mjd(int(t.MJD)), t.Start, t.Last, t.Sec, t.Offset)
}

func unpackHeader(b []byte) {
	order := binary.LittleEndian
	r := bytes.NewReader(b)
	before := r.Len()
	var fh FileHeader
	if err := binary.Read(r, order, &fh); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%#v, %d\n", fh, before - r.Len())
	if _, err := r.Seek(1024, 0); err != nil {
		log.Fatal("seek", err)
	}
	
	var p TSPoint
	if err := binary.Read(r, order, &p); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s\n", p)
}
