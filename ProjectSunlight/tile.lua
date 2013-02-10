require ("class")

Tile = class(function(t, sprite, id)
	t.sprite = spite
	t.id = id
end)

function Tile:__toString()
	return self.id
end

