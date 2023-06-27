CREATE TABLE public."_cbi_apikey_usage" (
	id serial4 NOT NULL,
	env int4 NOT NULL,
	api_key varchar(64) NOT NULL,
	request_count numeric NULL,
	request_length_total numeric NULL,
	response_size_total numeric NULL,
	response_size_total_mb numeric NULL,
	"date" date NOT NULL,
	CONSTRAINT "_cbi_apikey_usage_pkey" PRIMARY KEY (id),
	CONSTRAINT "_cbi_apikey_usage_vkey_unique" UNIQUE (env, api_key)
);
CREATE UNIQUE INDEX _cbi_apikey_usage_index_1 ON public._cbi_apikey_usage USING btree (env, api_key);