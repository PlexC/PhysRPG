extends Panel
#change to sprite2d and add below center container + panel 
#if inventory needs calc a lot
@onready var item_display: TextureRect = $ItemDisplay
@onready var amount: Label = $Label


func update(slot: InvSlot):
	if !slot or !slot.item:
		item_display.visible = false
		amount.visible = false
	else:
		item_display.visible = true
		item_display.texture = slot.item.texture
		item_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if slot.amount > 1:
			amount.visible = true
		amount.text = str(slot.amount)
