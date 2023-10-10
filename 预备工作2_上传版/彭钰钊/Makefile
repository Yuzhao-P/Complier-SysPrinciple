.PHONY: test1, clean
test1:
	arm-linux-gnueabihf-gcc Test1.s -o Test1.out -static -march=armv7-a -mfpu=vfpv3
	qemu-arm ./Test1.out
clean:
	rm -fr *.out