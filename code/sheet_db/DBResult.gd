class_name DBResult
extends RefCounted

var event: String
var version
var data
var error
var code
var update
var clear

func _init(event, payload: Dictionary):
	self.event = event
	self.version = payload.get('version')
	self.data = payload.get('data')
	self.error = payload.get('error')
	self.code = payload.get('code')
	self.update = payload.get('update')
	self.clear = payload.get('clear', false)

