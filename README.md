# Slash Warriors
Roguelike, Hack and Slash, Fast Paced, Endless
Fight as many as you can, stay alive as long as you can, earn upgrades.

See references:
Dynasty Warrior
Hyrule Warriors


This is an excellent question. It highlights the exact trade-off of using the Math Method: because you aren't using physics collisions, **you don't get a physical "impact point" to spawn your particle effects on.** If you hit 50 enemies at once, you have to fake where the weapon actually struck them, and you have to do it without melting the player's CPU.

Here is how you handle high-density hit effects in a Musou game, keeping your performance smooth.

### **1. Faking the Impact Point**

Since the dot product just tells you *if* an enemy is in the hit cone, you must mathematically decide where the hit spark goes.

* **The Basic Offset:** Don't spawn the particle at the enemy's root position (which is usually at their feet). Add a vertical offset to place it at chest height: `hit_position = enemy.global_position + Vector3(0, 1.0, 0)`.
* **The "Messy" Offset (Better):** If you hit 50 enemies and every spark spawns at the exact same relative pixel on their chest, it looks artificial. Add a tiny bit of random variance to the impact point.
* *Example:* `hit_position = enemy.global_position + Vector3(randf_range(-0.2, 0.2), randf_range(0.8, 1.2), randf_range(-0.2, 0.2))`


* **Directional Sparks:** Make your hit sparks rotate to face the player, or align them along the angle of the weapon swing, so they feel dynamic.

### **2. Particle Object Pooling (The Golden Rule Reprised)**

Just like your enemies, **never** use `instantiate()` for hit sparks or floating damage numbers during combat. Spawning 50 `GPUParticles3D` nodes in a single frame will cause severe micro-stutters.

1. **Create a VFX Pool:** On level load, instantiate a pool of 100 hit spark nodes and 50 floating damage number nodes. Keep them hidden in the scene tree.
2. **Request a Spark:** When your Math Method confirms a hit, ask the VFX Pool for an available spark.
3. **Emit and Recycle:** Move the spark to the faked impact point, set `emitting = true`, and start a short timer (e.g., 0.5 seconds). When the timer ends, the spark returns itself to the available pool.

### **3. Controlling Visual Clutter (The Musou Illusion)**

Dynasty Warriors games use clever visual tricks to make you *feel* like you are doing massive damage without actually rendering everything.

* **Cap the Visuals:** Even if you hit 50 enemies, you do not need 50 hit sparks. You can cap your VFX Pool to only ever show a maximum of 15 sparks at a time. The player's brain is processing too much chaos to notice that 35 enemies didn't get a spark, as long as the enemies still flinch and take damage.
* **Selective Damage Numbers:** Do not show floating damage numbers for every single hit on standard grunt enemies. It will create an unreadable wall of text. Instead:
* Only show damage numbers for Elite enemies or Bosses.
* Only show damage numbers for Critical Hits.
* **The Combo Approach:** Ditch individual damage numbers entirely. Instead, use a centralized UI "Combo Counter" that rapidly ticks up the Total Damage Dealt during a swing sequence (this is very common in modern action games).


* **Use "Hit Stop" Wisely:** A great way to sell the impact of hitting multiple enemies is to pause the player's attack animation for just a few milliseconds (e.g., 0.05 seconds) when a massive hit connects. It gives the swing a feeling of weight and "crunch" without needing more particles.

---

Would you like me to write out a script example of how to build the `VFXPool` for your hit sparks so you can easily call `VFXPool.spawn_hit_spark(position)` from anywhere in your game?





