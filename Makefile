
all:
	./rebar compile

run:
	ERL_LIBS=apps:deps erl +K true -name comet@127.0.0.1 -boot start_sasl -s comet_app -sasl errlog_type error
