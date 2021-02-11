local newdecoder = require 'Thirdparty.lunajson-master.src.lunajson.decoder'
local newencoder = require 'Thirdparty.lunajson-master.src.lunajson.encoder'
local sax = require 'Thirdparty.lunajson-master.src.lunajson.sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
