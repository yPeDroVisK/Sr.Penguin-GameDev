extends Resource
class_name ItemData

# Tipo de Items
enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE
}

# @export = aparece no Inspector do Godot para editar sem código
@export var id: String = ""               # Ex: "espada_ferro"
@export var display_name: String = ""     # Ex: "Espada de Ferro"
@export var description: String = ""      # Texto que aparece na UI
@export var icon: Texture2D               # Imagem do item (arraste no Inspector)
@export var max_stack: int = 1            # 1 = não empilha | 99 = empilha até 99
@export var is_usable: bool = false       # Pode usar com tecla?
@export var value: int = 0               # Valor em moedas
@export var item_type: ItemType = ItemType.CONSUMABLE

# Dados extras específicos de tipo (use apenas o que precisar)
@export var damage: int = 0              # Para armas
@export var defense: int = 0            # Para armaduras
@export var heal_amount: int = 0        # Para consumíveis
