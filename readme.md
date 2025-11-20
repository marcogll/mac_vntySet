# mac_vntySet — Instalación automática para macOS

Este script prepara un entorno de desarrollo completo en macOS con Homebrew, Zsh, Oh My Zsh, Oh My Posh, Node, Python, Docker, Portainer y más.
Todo se instala sin intervención usando el modo predeterminado **“A” (instalar todo)**.

---

## 🚀 Instalación

Ejecuta este comando en tu terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marcogll/mac_vntySet/refs/heads/main/install.sh)"
```

El script:

1. Instala Homebrew si no existe.
2. Instala herramientas base (Zsh, Git, Curl, etc.).
3. Configura Oh My Zsh + plugins.
4. Instala Oh My Posh + fuente Meslo.
5. Descarga tu `.zshrc` personalizado.
6. Instala Python, Node, Docker y Lazydocker.
7. Configura Portainer automáticamente.
8. Copia al portapapeles el comando `source ~/.zshrc`.

---

## 📂 Estructura

* **install.sh** – Script principal de instalación automática.
* **.zshrc.example** – Configuración base para tu shell.

---

## 🧩 Requisitos

* macOS (Intel o Apple Silicon).
* Conexión a internet.

---

## 🐳 Portainer

El script instala y levanta automáticamente Portainer en:

* **[https://localhost:9443](https://localhost:9443)**

Puedes entrar y configurar tu entorno Docker sin pasos extra.

---

## 🎨 Tema y shell

El entorno queda configurado con:

* **Oh My Posh** usando tema **Catppuccin**
* **Meslo Nerd Font** instalada automáticamente
* Plugins de Zsh:

  * Autocompletado avanzado
  * Autosuggestions
  * Syntax highlighting

---

## 🔁 Activación

Al final del proceso el instalador copia este comando al portapapeles:

```bash
source ~/.zshrc
```

Solo pégalo para activar toda la configuración.

---

## 🛠️ Actualizar o reinstalar

Puedes volver a ejecutar el instalador cuando quieras; es idempotente (no rompe nada).

---

## 📜 Licencia

MIT.
