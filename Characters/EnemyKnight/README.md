# CaballeroEnemigo

Enemigo de plataforma hecho como `CharacterBody2D`, siguiendo la estructura básica del jugador pero con IA.

## Animaciones
- Idle
- Walk
- Run
- Jump
- Fall
- Attack
- Hit
- Death

## IA
- Busca `Jugador1` mediante `target_path` o `find_child`.
- Lo sigue horizontalmente.
- Corre cuando está lejos y camina cuando se acerca.
- Salta si el jugador está por encima.
- Usa RayCast2D en los pies para no caminar fuera de la plataforma.
- Ataca dentro de `attack_distance`.
- La espada usa `AttackArea` únicamente durante los frames activos del golpe.

El script del jugador no es necesario modificar para que el enemigo funcione.
