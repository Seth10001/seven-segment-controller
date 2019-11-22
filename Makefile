PROJECT      = seven-segment-controller
BITFILE_PATH = $(PROJECT).runs/impl_1/SevenSegmentController_top.bit
CABLE_TYPE   = nexys4

.PHONY: default
default:

.PHONY: setup
setup:
	@make --directory=scripts/hooks hooks
	@make --directory=source/constraints constraints
	@brew bundle

.PHONY: clean-setup
clean-setup:
	@make --directory=scripts/hooks clean
	@make --directory=source/constraints clean


.PHONY: run
run: target/$(PROJECT).bit
	@if [ -f $(BITFILE_PATH) ]; then make --always-make $<; fi
	@xc3sprog -c $(CABLE_TYPE) $<

target/$(PROJECT).bit: | target
	ln -f $(BITFILE_PATH) $@

target:
	@mkdir -p target

.PHONY: clean
clean:
	@rm -rf target
