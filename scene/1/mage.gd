@tool
class_name Mage extends Minion


@export var bagua: Bagua:
	set(bagua_):
		bagua = bagua_
		bagua.minion = self
	get:
		return bagua
@export var inventory: Inventory:
	set(inventory_):
		inventory = inventory_
		inventory.minion = self
	get:
		return inventory
