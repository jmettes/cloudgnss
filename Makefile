build:
	@terraform get
	zip -r rtcm_lambda.zip rtcm_lambda.py pyrtcm

.PHONY: build
