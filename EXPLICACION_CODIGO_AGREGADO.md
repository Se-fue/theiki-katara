# Explicación del código agregado

Este documento explica los cambios incorporados al proyecto sin modificar los mapas originales.

## 1. Menú principal

### Archivos

- `UI/MenuPrincipal/menu_principal.tscn`: construye visualmente el menú.
- `UI/MenuPrincipal/menu_principal.gd`: controla todos sus botones y opciones.
- `UI/MenuPrincipal/fondo_menu.png`: fondo pixel art del bosque y las ruinas.

### Estructura visual de `menu_principal.tscn`

- `MenuPrincipal`: nodo raíz de tipo `Control`; ocupa toda la ventana.
- `Fondo`: muestra la imagen pixel art y la adapta a distintas resoluciones.
- `Oscurecer`: coloca una capa transparente sobre el fondo para mejorar la lectura.
- `Centro`: mantiene el contenido centrado sin importar el tamaño de la ventana.
- `ContenidoPrincipal`: organiza verticalmente el título, subtítulo y botones.
- `MarcoMenu`: dibuja el panel oscuro con borde azul alrededor de los botones.
- `BotonJugar`: cambia del menú a `Z1N1.tscn`.
- `BotonControles`: muestra las teclas del jugador.
- `BotonOpciones`: muestra volumen y pantalla completa.
- `BotonCreditos`: muestra el nombre del proyecto y sus autores.
- `BotonSalir`: termina la ejecución.
- `PanelControles`, `PanelOpciones` y `PanelCreditos`: permanecen ocultos hasta que se presiona su botón correspondiente.

Los recursos `StyleBoxFlat` controlan los colores, bordes, esquinas y estados visuales de los botones. `ThemeMenu` aplica esos estilos a toda la interfaz.

### Inicio del proyecto

En `project.godot`, `run/main_scene` apunta a:

```text
res://UI/MenuPrincipal/menu_principal.tscn
```

Por eso el menú aparece al ejecutar el proyecto. El botón JUGAR abre la escena original `Z1N1.tscn`; no fue necesario editar el mapa.

## 2. Corrección del ataque del jugador

La función `_start_attack()` está dentro del script incorporado en `Characters/J1/jugador_1.tscn`.

La corrección utiliza una sola animación (`AttackRight`). Cuando el personaje mira a la izquierda, `flip_h` refleja los mismos fotogramas. Esto impide mezclar `AttackLeft` y `AttackRight` y conserva correctamente el lado del ataque cuando el jugador permanece quieto.

Secuencia completa:

1. Marca `attacking = true` para impedir ataques simultáneos.
2. Oculta el sprite normal.
3. Muestra `AttackSprite`.
4. Detiene la animación anterior y regresa al fotograma cero.
5. Lee `mira`, que conserva la última dirección del jugador.
6. Refleja `AttackRight` si debe atacar hacia la izquierda.
7. Espera hasta terminar la animación.
8. Oculta `AttackSprite`, recupera el sprite normal y permite otro ataque.

## 3. Enemigo físico

### Archivos

- `Characters/EnemyFisico/enemy_fisico.tscn`: escena independiente del enemigo.
- `Characters/EnemyFisico/enemy_fisico.gd`: movimiento y detección.

El enemigo es un `CharacterBody2D`, por lo que utiliza gravedad y colisiones reales. Busca un nodo llamado `Jugador1`, calcula su distancia y lo persigue horizontalmente cuando entra en el rango de 300 píxeles. Si encuentra una pared mientras está apoyado en el piso, salta usando una fuerza semejante a la del jugador.

El enemigo no se agregó directamente a `Z1N1`; su escena permanece independiente para colocarla manualmente donde se necesite.

## 4. Archivos originales protegidos

Los mapas `Z1N1.tscn` y `Z1H1.tscn` no fueron modificados. Las incorporaciones se mantienen en carpetas independientes y el único cambio del jugador está limitado a la función visual de ataque explicada anteriormente.

