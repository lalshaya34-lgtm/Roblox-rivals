const canvas = document.getElementById("gameCanvas");
const ctx = canvas.getContext("2d");

const overlay = document.getElementById("overlay");
const startBtn = document.getElementById("startBtn");
const teamLabel = document.getElementById("teamLabel");
const statusLabel = document.getElementById("statusLabel");
const timerLabel = document.getElementById("timerLabel");
const healthFill = document.getElementById("healthFill");
const healthText = document.getElementById("healthText");
const weaponName = document.getElementById("weaponName");
const ammoLabel = document.getElementById("ammoLabel");
const scoreList = document.getElementById("scoreList");
const killFeed = document.getElementById("killFeed");

const keys = {};
const mouse = { x: canvas.width / 2, y: canvas.height / 2, down: false };

const weapons = [
  { name: "RIFLE", damage: 18, fireRate: 0.12, clip: 24, reserve: 96, reload: 1.1, color: "#60a5fa" },
  { name: "SMG", damage: 12, fireRate: 0.08, clip: 32, reserve: 120, reload: 1.0, color: "#34d399" },
  { name: "BURST", damage: 15, fireRate: 0.15, clip: 18, reserve: 72, reload: 1.25, color: "#fbbf24" },
  { name: "SHOTGUN", damage: 11, fireRate: 0.7, clip: 6, reserve: 30, reload: 1.8, color: "#f87171" },
  { name: "DMR", damage: 26, fireRate: 0.28, clip: 12, reserve: 48, reload: 1.45, color: "#a78bfa" },
  { name: "REVOLVER", damage: 32, fireRate: 0.38, clip: 8, reserve: 32, reload: 1.6, color: "#f8fafc" }
];

const state = {
  phase: "lobby",
  roundTime: 30,
  score: 0,
  kills: 0,
  deaths: 0,
  killFeedLines: [],
  pickups: [],
  bots: [],
  bullets: [],
  lastTime: 0,
  started: false,
  spawnTimer: 0
};

const player = {
  x: canvas.width / 2,
  y: canvas.height / 2,
  radius: 16,
  speed: 220,
  angle: 0,
  health: 100,
  maxHealth: 100,
  weaponIndex: 0,
  ammo: { clip: weapons[0].clip, reserve: weapons[0].reserve },
  reloadTimer: 0,
  sprinting: false,
  team: "RED",
  kills: 0,
  deaths: 0,
  isAlive: true,
  shootCooldown: 0
};

function resetPlayer() {
  player.x = canvas.width / 2;
  player.y = canvas.height / 2;
  player.health = 100;
  player.maxHealth = 100;
  player.weaponIndex = 0;
  player.ammo = { clip: weapons[0].clip, reserve: weapons[0].reserve };
  player.reloadTimer = 0;
  player.sprinting = false;
  player.isAlive = true;
  player.shootCooldown = 0;
}

function randomBetween(min, max) {
  return Math.random() * (max - min) + min;
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function makePickup(type, x, y) {
  state.pickups.push({
    type,
    x,
    y,
    radius: 12,
    ttl: 10
  });
}

function spawnPickups() {
  const types = ["health", "ammo", "boost"];
  for (let i = 0; i < 5; i += 1) {
    const type = types[Math.floor(Math.random() * types.length)];
    const x = randomBetween(80, canvas.width - 80);
    const y = randomBetween(80, canvas.height - 80);
    makePickup(type, x, y);
  }
}

function createBot() {
  const angle = Math.random() * Math.PI * 2;
  const radius = 18;
  const x = Math.random() * (canvas.width - 100) + 50;
  const y = Math.random() * (canvas.height - 100) + 50;
  const team = Math.random() > 0.5 ? "RED" : "BLUE";
  const color = team === "RED" ? "#f87171" : "#60a5fa";

  state.bots.push({
    x,
    y,
    radius,
    speed: 80 + Math.random() * 30,
    angle,
    health: 100,
    maxHealth: 100,
    team,
    color,
    shootCooldown: 0
  });
}

function initBots(count) {
  state.bots = [];
  for (let i = 0; i < count; i += 1) {
    createBot();
  }
}

function addKillFeed(text) {
  state.killFeedLines.unshift(text);
  if (state.killFeedLines.length > 6) {
    state.killFeedLines.pop();
  }
}

function updateScoreboard() {
  const rows = [
    { name: "YOU", value: player.kills },
    { name: "DEATHS", value: player.deaths },
    { name: "BOTS", value: state.bots.length }
  ];

  scoreList.innerHTML = rows.map((r) => `
    <div class="scoreRow">
      <span>${r.name}</span>
      <span>${r.value}</span>
    </div>
  `).join("");
}

function updateHUD() {
  const weapon = weapons[player.weaponIndex];
  weaponName.textContent = weapon.name;
  ammoLabel.textContent = `${player.ammo.clip} / ${player.ammo.reserve}`;

  const healthRatio = clamp(player.health / player.maxHealth, 0, 1);
  healthFill.style.width = `${healthRatio * 100}%`;
  healthText.textContent = `${Math.floor(player.health)} / ${player.maxHealth}`;

  teamLabel.textContent = player.team;

  if (state.phase === "lobby") {
    statusLabel.textContent = "LOBBY";
  } else if (state.phase === "live") {
    statusLabel.textContent = "LIVE";
  } else if (state.phase === "roundOver") {
    statusLabel.textContent = "ROUND OVER";
  }

  timerLabel.textContent = `00:${String(Math.max(0, Math.ceil(state.roundTime))).padStart(2, "0")}`;

  const feed = state.killFeedLines.slice(0, 4).map((line) => `<div class="killLine">${line}</div>`).join("");
  killFeed.innerHTML = feed;

  updateScoreboard();
}

function startReload() {
  const weapon = weapons[player.weaponIndex];
  if (player.reloadTimer > 0 || player.ammo.clip >= weapon.clip || player.ammo.reserve <= 0) return;
  player.reloadTimer = weapon.reload;
}

function cycleWeapon(direction) {
  player.weaponIndex = (player.weaponIndex + direction + weapons.length) % weapons.length;
  const weapon = weapons[player.weaponIndex];
  if (player.ammo.clip <= 0 && player.ammo.reserve > 0) {
    startReload();
  }
  updateHUD();
}

function shootWeapon() {
  const weapon = weapons[player.weaponIndex];
  if (player.reloadTimer > 0) return;
  if (player.ammo.clip <= 0) {
    startReload();
    return;
  }

  player.shootCooldown = weapon.fireRate;
  player.ammo.clip -= 1;

  const bullet = {
    x: player.x,
    y: player.y,
    angle: player.angle,
    speed: 540,
    radius: 4,
    life: 1.4,
    color: weapon.color,
    owner: "player"
  };

  state.bullets.push(bullet);

  if (weapon.name === "SHOTGUN") {
    for (let i = -1; i <= 1; i += 1) {
      state.bullets.push({
        x: player.x,
        y: player.y,
        angle: player.angle + i * 0.25,
        speed: 540,
        radius: 4,
        life: 1.25,
        color: weapon.color,
        owner: "player"
      });
    }
  }
}

function damageBot(bot, amount) {
  bot.health -= amount;
  if (bot.health <= 0) {
    player.kills += 1;
    addKillFeed("YOU eliminated a rival");
    const index = state.bots.indexOf(bot);
    if (index >= 0) {
      state.bots.splice(index, 1);
    }
    createBot();
  }
}

function damagePlayer(amount) {
  player.health -= amount;
  if (player.health <= 0) {
    player.deaths += 1;
    addKillFeed("You were eliminated");
    player.health = player.maxHealth;
    player.x = canvas.width / 2;
    player.y = canvas.height / 2;
    player.ammo = { clip: weapons[player.weaponIndex].clip, reserve: weapons[player.weaponIndex].reserve };
  }
}

function applyPickup(pickup) {
  if (pickup.type === "health") {
    player.health = Math.min(player.maxHealth, player.health + 25);
    addKillFeed("Health boost collected");
  } else if (pickup.type === "ammo") {
    const weapon = weapons[player.weaponIndex];
    player.ammo.reserve += weapon.reserve * 0.35;
    addKillFeed("Ammo refilled");
  } else if (pickup.type === "boost") {
    player.speed = 310;
    setTimeout(() => {
      player.speed = 220;
    }, 2200);
    addKillFeed("Speed boost active");
  }
}

function updatePlayer(dt) {
  const moveX = (keys.d ? 1 : 0) - (keys.a ? 1 : 0);
  const moveY = (keys.s ? 1 : 0) - (keys.w ? 1 : 0);
  const magnitude = Math.hypot(moveX, moveY) || 1;

  let speed = player.speed;
  if (keys.Shift) {
    speed *= 1.45;
    player.sprinting = true;
  } else {
    player.sprinting = false;
  }

  player.x += (moveX / magnitude) * speed * dt;
  player.y += (moveY / magnitude) * speed * dt;

  player.x = clamp(player.x, 20, canvas.width - 20);
  player.y = clamp(player.y, 20, canvas.height - 20);

  const dx = mouse.x - player.x;
  const dy = mouse.y - player.y;
  player.angle = Math.atan2(dy, dx);

  if (player.shootCooldown > 0) {
    player.shootCooldown -= dt;
  }

  if (mouse.down && player.shootCooldown <= 0) {
    shootWeapon();
  }

  if (player.reloadTimer > 0) {
    player.reloadTimer -= dt;
    if (player.reloadTimer <= 0) {
      const weapon = weapons[player.weaponIndex];
      const needed = weapon.clip - player.ammo.clip;
      const loaded = Math.min(needed, player.ammo.reserve);
      player.ammo.clip += loaded;
      player.ammo.reserve -= loaded;
    }
  }

  for (let i = state.pickups.length - 1; i >= 0; i -= 1) {
    const pickup = state.pickups[i];
    const dist = Math.hypot(pickup.x - player.x, pickup.y - player.y);
    if (dist < pickup.radius + player.radius) {
      applyPickup(pickup);
      state.pickups.splice(i, 1);
    }
  }
}

function updateBots(dt) {
  for (const bot of state.bots) {
    const dx = player.x - bot.x;
    const dy = player.y - bot.y;
    const dist = Math.hypot(dx, dy) || 1;
    bot.angle = Math.atan2(dy, dx);

    if (dist > 180) {
      bot.x += (dx / dist) * bot.speed * dt;
      bot.y += (dy / dist) * bot.speed * dt;
    }

    bot.x = clamp(bot.x, 20, canvas.width - 20);
    bot.y = clamp(bot.y, 20, canvas.height - 20);

    if (dist < 260 && bot.shootCooldown <= 0) {
      const bullet = {
        x: bot.x,
        y: bot.y,
        angle: bot.angle,
        speed: 420,
        radius: 4,
        life: 1.5,
        color: bot.color,
        owner: "bot"
      };
      state.bullets.push(bullet);
      bot.shootCooldown = 1.5 + Math.random() * 0.8;
    }

    bot.shootCooldown -= dt;
  }
}

function updateBullets(dt) {
  for (let i = state.bullets.length - 1; i >= 0; i -= 1) {
    const bullet = state.bullets[i];
    bullet.x += Math.cos(bullet.angle) * bullet.speed * dt;
    bullet.y += Math.sin(bullet.angle) * bullet.speed * dt;
    bullet.life -= dt;

    if (bullet.life <= 0 || bullet.x < 0 || bullet.y < 0 || bullet.x > canvas.width || bullet.y > canvas.height) {
      state.bullets.splice(i, 1);
      continue;
    }

    if (bullet.owner === "player") {
      for (const bot of state.bots) {
        const dist = Math.hypot(bullet.x - bot.x, bullet.y - bot.y);
        if (dist < bullet.radius + bot.radius) {
          damageBot(bot, weapons[player.weaponIndex].damage);
          state.bullets.splice(i, 1);
          break;
        }
      }
    } else if (bullet.owner === "bot") {
      const dist = Math.hypot(bullet.x - player.x, bullet.y - player.y);
      if (dist < bullet.radius + player.radius) {
        damagePlayer(12);
        state.bullets.splice(i, 1);
      }
    }
  }
}

function updatePickups(dt) {
  for (let i = state.pickups.length - 1; i >= 0; i -= 1) {
    const pickup = state.pickups[i];
    pickup.ttl -= dt;
    if (pickup.ttl <= 0) {
      state.pickups.splice(i, 1);
    }
  }
}

function updateRound(dt) {
  if (state.phase === "live") {
    state.roundTime -= dt;
    if (state.roundTime <= 0) {
      state.phase = "roundOver";
      state.roundTime = 6;
      addKillFeed(`Round over — score: ${player.kills}`);
    }
  } else if (state.phase === "roundOver") {
    state.roundTime -= dt;
    if (state.roundTime <= 0) {
      resetPlayer();
      initBots(6);
      spawnPickups();
      state.phase = "lobby";
      state.roundTime = 30;
      overlay.style.display = "grid";
      statusLabel.textContent = "LOBBY";
    }
  }
}

function startGame() {
  overlay.style.display = "none";
  state.started = true;
  state.phase = "live";
  state.roundTime = 30;
  state.killFeedLines = [];
  resetPlayer();
  initBots(6);
  spawnPickups();
  updateHUD();
}

function drawArena() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  ctx.fillStyle = "#0f172a";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.strokeStyle = "rgba(96, 165, 250, 0.85)";
  ctx.lineWidth = 3;
  ctx.strokeRect(28, 28, canvas.width - 56, canvas.height - 56);

  ctx.strokeStyle = "rgba(56, 189, 248, 0.35)";
  ctx.beginPath();
  ctx.arc(canvas.width / 2, canvas.height / 2, 150, 0, Math.PI * 2);
  ctx.stroke();

  for (const pickup of state.pickups) {
    ctx.fillStyle = pickup.type === "health" ? "#22c55e" : pickup.type === "ammo" ? "#f59e0b" : "#3b82f6";
    ctx.beginPath();
    ctx.arc(pickup.x, pickup.y, pickup.radius, 0, Math.PI * 2);
    ctx.fill();
  }

  for (const bot of state.bots) {
    ctx.beginPath();
    ctx.fillStyle = bot.color;
    ctx.arc(bot.x, bot.y, bot.radius, 0, Math.PI * 2);
    ctx.fill();

    ctx.beginPath();
    ctx.strokeStyle = "#e2e8f0";
    ctx.moveTo(bot.x, bot.y);
    ctx.lineTo(bot.x + Math.cos(bot.angle) * 18, bot.y + Math.sin(bot.angle) * 18);
    ctx.stroke();
  }

  for (const bullet of state.bullets) {
    ctx.fillStyle = bullet.color;
    ctx.beginPath();
    ctx.arc(bullet.x, bullet.y, bullet.radius, 0, Math.PI * 2);
    ctx.fill();
  }

  ctx.save();
  ctx.translate(player.x, player.y);
  ctx.rotate(player.angle);
  ctx.fillStyle = player.team === "RED" ? "#ef4444" : "#3b82f6";
  ctx.fillRect(0, -5, 18, 10);
  ctx.restore();

  ctx.beginPath();
  ctx.strokeStyle = "rgba(255,255,255,0.9)";
  ctx.lineWidth = 1.5;
  ctx.moveTo(mouse.x - 7, mouse.y);
  ctx.lineTo(mouse.x + 7, mouse.y);
  ctx.moveTo(mouse.x, mouse.y - 7);
  ctx.lineTo(mouse.x, mouse.y + 7);
  ctx.stroke();
}

function gameLoop(timestamp) {
  const dt = Math.min(0.032, (timestamp - (state.lastTime || timestamp)) / 1000 || 0.016);
  state.lastTime = timestamp;

  if (state.started) {
    if (state.phase === "live") {
      updatePlayer(dt);
      updateBots(dt);
      updateBullets(dt);
      updatePickups(dt);
      updateRound(dt);
    } else if (state.phase === "roundOver") {
      updateRound(dt);
    }
  }

  updateHUD();
  drawArena();
  requestAnimationFrame(gameLoop);
}

window.addEventListener("keydown", (event) => {
  keys[event.key] = true;
  keys[event.key.toLowerCase()] = true;

  if (event.key === "q" || event.key === "Q") {
    cycleWeapon(1);
  }

  if (event.key === "r" || event.key === "R") {
    startReload();
  }
});

window.addEventListener("keyup", (event) => {
  keys[event.key] = false;
  keys[event.key.toLowerCase()] = false;
});

canvas.addEventListener("mousemove", (event) => {
  const rect = canvas.getBoundingClientRect();
  mouse.x = ((event.clientX - rect.left) / rect.width) * canvas.width;
  mouse.y = ((event.clientY - rect.top) / rect.height) * canvas.height;
});

canvas.addEventListener("mousedown", () => {
  mouse.down = true;
});

window.addEventListener("mouseup", () => {
  mouse.down = false;
});

startBtn.addEventListener("click", () => {
  startGame();
});

resetPlayer();
initBots(6);
spawnPickups();
updateHUD();
requestAnimationFrame(gameLoop);
