# Slash Warriors
Roguelike, Hack and Slash, Fast Paced, Endless
Fight as many as you can, stay alive as long as you can, earn upgrades.

See references:
Dynasty Warrior
Hyrule Warriors


### **3. The Math Method (The "Musou Optimization")**

If you want true Dynasty Warriors scale (100+ enemies on screen), relying on physics collisions for every single weapon swing will severely lag your game. The industry standard for this is to skip physics and use math.

* **The Setup:** Give your player a massive, invisible `Area3D` radius (e.g., 5 meters). This keeps track of all enemies in the general vicinity.
* **The Logic:** When you swing your sword, you don't use weapon collision. Instead, you loop through every enemy currently in your radius and use a **Dot Product** to check if they are standing in front of your character.

To find out if an enemy is inside your attack arc, you compare the player's forward vector with the direction vector pointing to the enemy:

$\text{Dot} = \hat{V}_{\text{player\_forward}} \cdot \hat{V}_{\text{direction\_to\_enemy}}$

If your attack is a wide sweep (e.g., a 180° arc in front of the player), you check the result. A dot product returns a value between **1.0** (directly in front) and **-1.0** (directly behind).

If $ \text{Dot} > 0 $, the enemy is in the front 180° arc and gets hit. This calculation is incredibly cheap for the CPU, allowing you to hit 50 enemies in a single frame without dropping your framerate.

---

### **The Golden Rule: The "Already Hit" Array**

No matter which method you choose, you will run into a massive problem: Godot runs at 60+ frames per second. If your sword overlaps an enemy for 10 frames, it will hit them 10 times in a single swing.

To fix this, you must implement an "Already Hit" array:

1. Create an empty Array variable in your attack script: `var enemies_hit_this_swing = []`
2. When an enemy is detected by your Area/Cast/Math, check if they are in the array.
3. If they are *not* in the array, apply damage and `append()` them to the array.
4. When the attack animation finishes, clear the array: `enemies_hit_this_swing.clear()`

This ensures that one swing = one instance of damage per enemy, no matter how long the weapon touches them.

Would you like me to write out a quick Godot GDScript example for one of these specific methods?
