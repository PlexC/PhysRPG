class_name PlayerButton extends BattleActorButton

func _ready() -> void:
	set_data(Savemanager.party[get_index()])

func _on_data_defeated()->void:
	self.modulate = Color.BLACK
