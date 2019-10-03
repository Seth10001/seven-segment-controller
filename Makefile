.PHONY: default
default:

setup:
	@make --directory=scripts/hooks hooks
	@make --directory=source/constraints constraints

clean:
	@make --directory=scripts/hooks clean
	@make --directory=source/constraints clean
