@tool
class_name Mage extends PanelContainer


@export var battle: Battle

@export var statistic: Statistic:
	set(statistic_):
		statistic = statistic_
		statistic.mage = self
	get:
		return statistic

@export var conveyor: Conveyor:
	set(conveyor_):
		conveyor = conveyor_
		conveyor.mage = self
	get:
		return conveyor

@export var grimoire: Grimoire:
	set(grimoire_):
		grimoire = grimoire_
		grimoire.mage = self
	get:
		return grimoire

@export var bagua: Bagua:
	set(bagua_):
		bagua = bagua_
		bagua.mage = self
	get:
		return bagua

@export var inventory: Inventory:
	set(inventory_):
		inventory = inventory_
		inventory.mage = self
	get:
		return inventory
