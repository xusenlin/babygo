# Run this on Linux

.PHONEY: test2 test

all: test

test.s: main.go runtime.go t1/test.go
	ln -sf ../t1/test.go t/source.go
	go run main.go > /tmp/test.s && cp /tmp/test.s test.s

test.o: test.s runtime.s
	as -o test.o test.s runtime.s

test.out: test.o
	ld -o test.out test.o

test: test.out t/expected.1
	./test.sh

# to learn Go's assembly
sample/sample.s: sample/sample.go
	go tool compile -N -S sample/sample.go > sample/sample.s

t1/test: t1/test.go
	go build -o t1/test t1/test.go

t/expected.1: t1/test
	t1/test 1> t/expected.1

# self compiler
self.s: main.go runtime.go t2/self.go
	ln -sf ../t2/self.go t/source.go
	go run main.go > /tmp/self.s && cp /tmp/self.s self.s

self.o: self.s
	as -o self.o self.s runtime.s

self: self.o
	ld -o self self.o

test2: self
	./self > self2.s
	go run t2/self.go > /tmp/self2.s
	diff self2.s /tmp/self2.s && echo 'ok'

fmt: *.go t1/*.go t2/*.go
	gofmt -w *.go t*/*.go

clean:
	rm -f test.s test.o test.out t1/test
	rm -f self self.o self.s

