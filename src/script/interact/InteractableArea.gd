class_name InteractableArea extends Area2D

## Sinal emitido quando o jogador interage
signal interacted(interactor: Node)
## Sinal emitido quando o jogador entra na área
signal player_entered(player: Node)
## Sinal emitido quando o jogador sai da área
signal player_exited(player: Node)

@export_group("Configuração")
@export var ativo: bool = true
@export var uma_vez_so: bool = false       # desativa após primeira interação
@export var tecla_interacao: StringName = "interact"

@export_group("Prompt")
@export var mostrar_prompt: bool = true
@export var texto_prompt: String = "":
	set(valor):
		texto_prompt = valor
		if _prompt:
			_prompt.text = valor
@export var prompt_node: NodePath           # aponta para um Label/Control

var _player_dentro: Node = null
var _ja_interagiu: bool = false
var _prompt: Node = null

func _ready() -> void:
	body_entered.connect(_ao_entrar)
	body_exited.connect(_ao_sair)
	if prompt_node:
		_prompt = get_node(prompt_node)
		_prompt.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if not ativo or _ja_interagiu:
		return
	if _player_dentro == null:
		return
	if Input.is_action_just_pressed(tecla_interacao):
		_interagir()

func _ao_entrar(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_dentro = body
		_mostrar_prompt(true)
		player_entered.emit(body)
		print_debug("Player entrou")

func _ao_sair(body: Node) -> void:
	if body != _player_dentro:
		return
	_player_dentro = null
	_mostrar_prompt(false)
	player_exited.emit(body)

func _interagir() -> void:
	interacted.emit(_player_dentro)
	if uma_vez_so:
		_ja_interagiu = true
		ativo = false
		_mostrar_prompt(false)

func _mostrar_prompt(visivel: bool) -> void:
	if mostrar_prompt and _prompt:
		_prompt.text = texto_prompt  # sempre atualiza antes de mostrar
		_prompt.visible = visivel

func resetar() -> void:
	## Reativa a área externamente
	_ja_interagiu = false
	ativo = true
