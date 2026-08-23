class_name Inventory extends Resource 

@export var slots: Array[InvSlot]

signal update

func insert(item: Item):
	var itemslots = slots.filter(func(slot):return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslot = slots.filter(func(slot):return slot.item == null)
		if !emptyslot.is_empty():
			emptyslot[0].item = item
			emptyslot[0].amount = 1
	update.emit()
