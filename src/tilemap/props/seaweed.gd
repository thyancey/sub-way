extends Node2D


@export_enum("green", "pink", "blue") var variant: String = "green"
@export var green_frames: SpriteFrames
@export var pink_frames: SpriteFrames
@export var blue_frames: SpriteFrames

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
    randomize()
    _set_variant_frames()
    _play_random_animation()

func _set_variant_frames():
    match variant:
        "green":
            sprite.sprite_frames = green_frames
        "pink":
            sprite.sprite_frames = pink_frames
        "blue":
            sprite.sprite_frames = blue_frames

func _play_random_animation():
    var anims = sprite.sprite_frames.get_animation_names()
    if anims.size() > 0:
        var random_anim = anims[randi() % anims.size()]
        sprite.animation = random_anim
        sprite.play()
