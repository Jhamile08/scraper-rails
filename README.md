# 🛠️ Guía para Clonar y Ejecutar un Proyecto Ruby on Rails

Este documento te guía paso a paso para clonar un proyecto Ruby on Rails y ejecutarlo en tu máquina, utilizando:

- **Ruby 3.3.5**
- **Rails 7.2.2.1**
- **Bundler (última compatible)**

---

## 📥 1. Clonar el Repositorio

```bash
git clone https://github.com/Jhamile08/scraper-rails.git
cd scraper-rails
```
💎 2. Instalar Ruby 3.3.5
Usando rbenv (recomendado)
Instalar dependencias:
```bash
sudo apt update
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev
```
Instalar rbenv y ruby-build:
```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
```
```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```
Instalar Ruby 3.3.5:
```bash
rbenv install 3.3.5
rbenv global 3.3.5
ruby -v  # Debería mostrar ruby 3.3.5
```
🚂 3. Instalar Rails 7.2.2.1
```bash
gem install rails -v 7.2.2.1
rails -v  # Debería mostrar Rails 7.2.2.1
```
📦 4. Instalar Bundler
```bash
gem install bundler
bundle -v  # Confirma la versión instalada
```
📁 5. Instalar las Dependencias del Proyecto
Desde la raíz del proyecto:
```bash
bundle install
```
⚠️ Si ves errores relacionados con gems específicas, asegúrate de tener las herramientas de compilación instaladas (build-essential, libssl-dev, etc).


✅ Confirmaciones Rápidas
```bash
ruby -v      # ruby 3.3.5
rails -v     # Rails 7.2.2.1
bundle -v    # Bundler instalado
```
📝 Notas Finales
Si el proyecto tiene un archivo .ruby-version, puedes hacer que rbenv lo use automáticamente.

Si hay errores con gemas nativas (como pg, nokogiri, etc.), instala sus dependencias del sistema.

Usa siempre bundle exec para ejecutar comandos definidos en el Gemfile.lock.

