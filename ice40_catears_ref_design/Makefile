FPGA_PKG = sg48
FPGA_TYPE = up5k

all: build/left.bin build/right.bin

sudo-prog-left: build/left.bin
	sudo iceprog build/left.bin

sudo-prog-right: build/right.bin
	sudo iceprog build/right.bin

build/left.bin: *.sv
	mkdir -p build/
	yosys -ql build/yosys-left.log -p 'synth_ice40 -top nekomimi_left -json build/left.json' *.sv
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json build/left.json --pcf catears.pcf --asc build/left.asc
	icepack build/left.asc build/left.bin

build/right.bin: *.sv
	mkdir -p build/
	yosys -ql build/yosys-right.log -p 'synth_ice40 -top nekomimi_right -json build/right.json' *.sv
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json build/right.json --pcf catears.pcf --asc build/right.asc
	icepack build/right.asc build/right.bin

clean:
	rm -r build

.PHONY: all clean
