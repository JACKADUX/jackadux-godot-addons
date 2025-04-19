class_name Maybe

enum Type {
	NOTHING,
	JUST,
}
var _type : Type
var _value : Variant

func _to_string():
	return "Maybe::%s<%s>"%[Type.keys()[_type], str(_value)]

func copy(other_maybe:Maybe) -> Maybe:
	_type = other_maybe._type
	_value = other_maybe._value
	return self

func is_nothing():
	return _type == Type.NOTHING
	
func map(fn:Callable, error=null) -> Maybe:
	if is_nothing():
		return self
	return maybe(fn.call(_value), error)

func await_map(fn:Callable, error=null) -> Maybe:
	if is_nothing():
		return self
	return maybe(await fn.call(_value), error)

func get_value():
	return _value
	
func pprint():
	print(JSON.stringify(get_value(), "\t"))

static func maybe(value, error=null) -> Maybe:
	if value is Maybe:
		return value
	if value != null:
		return Just(value)
	else:
		return Nothing(error)
		
static func Just(value) -> Maybe:
	var mb = Maybe.new()
	mb._type = Type.JUST
	mb._value = value
	return mb

static func Nothing(error) -> Maybe:
	var mb = Maybe.new()
	mb._type = Type.NOTHING
	mb._value = error
	return mb
