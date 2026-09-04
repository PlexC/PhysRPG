extends Panel
#change to sprite2d and add below center container + panel 
#if inventory needs calc a lot
@onready var item_display: TextureRect = $ItemDisplay
@onready var amount: Label = $Label


signal item_used

var item_slot: InvSlot = null


func update(slot: InvSlot):
	item_slot = slot
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


func _on_pressed() -> void:
	if item_slot == null or item_slot.item == null:
		print("nothin in the slot")
		return
	print("Item detected! Internal Name is: '", item_slot.item.name, "'")
	if item_slot.item.name == "potion":
		#only 1 character rn
		var knight = Savemanager.party[0]
			
		if knight.hp < knight.hp_max:
			knight.healhurt(100)
			item_slot.amount -= 1
			if item_slot.amount <= 0:
				item_slot.item = null
			update(item_slot)
			item_used.emit()
		else:
			print("hp full")
	else:
		print("FAIL: The code does not recognize this item as a Potion")
