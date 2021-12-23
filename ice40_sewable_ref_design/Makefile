PROJ_NAME = demo
CLK_FREQ = 16 # MHz

# Should not need to be changed
FPGA_PKG = sg48
FPGA_TYPE = up5k
PCF = ice40_wearable_v1.pcf

sudo-prog: ${PROJ_NAME}.bin
	sudo iceprog ${PROJ_NAME}.bin

${PROJ_NAME}: ${PROJ_NAME}.bin

${PROJ_NAME}.json: *.v
	yosys -ql $(subst .json,,$@)-yosys.log -p 'synth_ice40 -top $(subst .json,,$@) -json $@' *.v

${PROJ_NAME}.asc: ${PROJ_NAME}.json
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json $< --pcf ${PCF} --freq ${CLK_FREQ} --asc $@

${PROJ_NAME}.rpt: ${PROJ_NAME}.asc
	icetime -d ${FPGA_TYPE} -mtr $@ $<

${PROJ_NAME}.bin: ${PROJ_NAME}.asc
	icepack $< $@

clean:
	rm -f ${PROJ_NAME}.json ${PROJ_NAME}.asc ${PROJ_NAME}.rpt ${PROJ_NAME}.bin

all: top

.PHONY: all clean
