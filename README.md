# Vox Vacui

*Itch.io link: <https://kafkastudios.itch.io/vox-vacui>*

[![Godot](https://img.shields.io/badge/Godot-4.5.1-478cbf)](https://godotengine.org)
[![Language](https://img.shields.io/badge/Language-GDScript-blueviolet)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
[![Tests](https://img.shields.io/badge/Tests-~210%20passing-brightgreen)](./tests)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-critical)](#license)
[![Download on itch.io](https://img.shields.io/badge/Download%20on-itch.io-fa5c5c)](https://kafkastudios.itch.io/vox-vacui)

> "Мы рады подтвердить ваше официальное назначение в экипаж миссии Vox Vacui. 
>
> Мы готовимся к запуску, вставайте!"
>
> "We are pleased to officially confirm your assignment to join the crew of the Vox Vacui mission. 
>
> We are preparing for launch. Rise up!"

Vox Vacui is a 2D physics survival game. You play a cosmonaut adrift in deep space. To keep going you break down asteroid fragments, harvest their resources, and bring them back to the mothership.

## Table of contents

- [Requirements](#requirements)
- [Project structure](#project-structure)
- [License](#license)
- [Credits](#credits)

## Requirements

Godot **4.5.1** with the **Forward Plus** renderer. Older engine versions will not open the project.

## Project structure

```
res://
├── autoloads/       # global singletons (state, events, audio, scene changes)
├── scenes/
│   ├── levels/      # menus, space levels, ship interior, tutorial
│   ├── player/      # player body and death particles
│   ├── asteroids/   # asteroid bodies and breakable fragments
│   ├── enemies/     # the aliens
│   ├── bullets/     # player and boss bullets
│   ├── modulars/    # gameplay modules (gravity, damage, shooting, camera shake)
│   ├── space_bodies/# shared body base, planets, sun, orbit
│   ├── black_hole/  # black holes and supermassive variants
│   ├── spaceship/   # mothership, interior, diary, monitor UI
│   ├── ui/          # HUD and shared UI scripts
│   ├── cutscenes/   # story scenes and credits
│   └── start_limbo.tscn  # main scene
├── sound_effects/   # SFX
├── music/           # music tracks
├── sprites/         # art assets
├── shaders/         # .gdshader files
├── fonts/           # .ttf fonts
└── tests/           # gdUnit4 suites
```

## License

All rights reserved. No open source license applies to this project. Permission to use, modify, or redistribute the code and assets is not granted.

## Credits

Vox Vacui is made by KafkaStudios.