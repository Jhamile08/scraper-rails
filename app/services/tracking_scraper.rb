require "selenium-webdriver"
require "json"

class TrackingScraper
  def self.run
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless") # ⬅️ Opcional: Ejecutar sin interfaz gráfica
    driver = Selenium::WebDriver.for :chrome, options: options

    data = []

    begin
      driver.navigate.to "https://admin.bigsmart.mx/login"

      # Ingresar credenciales
      driver.find_element(:id, "email").send_keys("hhbd_007@yahoo.com")
      driver.find_element(:id, "password").send_keys("Bravozulu2024")
      driver.find_element(:css, 'button[type="submit"]').click

      wait = Selenium::WebDriver::Wait.new(timeout: 300) # ⬅️ Espera de hasta 300 segundos

      # Esperar a que desaparezca el spinner de carga
      wait.until { driver.find_elements(css: ".loading").empty? }
      puts "✔️ Carga completada"

      # Buscar el enlace de tracking
      tracking_link = wait.until { driver.find_element(css: 'a[data-flag="tracking"]') }
      href = tracking_link.attribute("href")
      puts "✔️ Tracking link encontrado: #{href}"

      # Navegar al link de tracking
      driver.navigate.to href

      # Esperar a que se cargue el contenido de la página con clase col-12
      row_div = wait.until { driver.find_element(css: ".col-12") }
      puts "✔️ Se encontró el div con clase 'col-12'"

      # Esperar a que el overlay desaparezca antes de intentar hacer clic en el botón de fecha
      wait.until { driver.find_elements(css: "#loading-mask[style*='display: block']").empty? }
      puts "✔️ Overlay desaparecido"

      # Buscar el botón para cambiar la fecha con la clase 'big__trackingpicker'
      date_button = wait.until { driver.find_element(css: ".big__trackingpicker") }
      puts "✔️ Botón de fecha encontrado"

      # Hacer clic en el botón de fecha
      date_button.click
      puts "✔️ Botón de fecha clickeado"

      # Esperar a que el calendario se despliegue
      wait.until { driver.find_element(css: ".react-datepicker") }
      puts "✔️ Calendario desplegado"

      day = "003"  # Cambia este valor según la fecha que necesites (Ej: "002" para el 2 de febrero)

      # Esperar y encontrar el día seleccionado dinámicamente
      day_element = wait.until { driver.find_element(css: ".react-datepicker__day--#{day}") }
      puts "✔️ Día #{day.to_i} encontrado"

      # Hacer clic en el día seleccionado
      day_element.click
      puts "✔️ Fecha cambiada a #{day.to_i} de febrero"
      # Esperar a que se cargue el div con la clase 'tracking-table'
      tracking_table = wait.until { driver.find_element(css: ".tracking-table") }
      puts "✔️ Div con clase 'tracking-table' encontrado"
      # Buscar el div 'card-body' dentro de 'tracking-table'
      card_body = tracking_table.find_element(css: ".tracking-table .card-body")
      puts "✔️ Div con clase 'card-body' encontrado dentro de 'tracking-table'"

      # Encontrar el elemento rt-tbody dentro de card_body
      rt_body = card_body.find_element(css: ".rt-tbody")
      puts "✔️ rt-body encontrado dentro del 'card-body'"
      wait = Selenium::WebDriver::Wait.new(timeout: 20) # Espera hasta 20s

      begin
        # Esperar hasta que la tabla se cargue
        wait.until { driver.find_element(css: ".rt-tbody") }

        # Buscar todas las filas dentro de la tabla
        filas = driver.find_elements(css: ".rt-tr-group")

        nombre = "Mauricio"
        contador = 0

        filas.each do |fila|
          begin
            # Buscar el <p> dentro de cada fila
            texto_p = fila.find_element(xpath: ".//p[contains(text(), '#{nombre}')]")
            
            if texto_p
              contador += 1
              puts "✔️ Se encontró el texto '#{nombre}' (número #{contador})."

              # Si es el tercer Juan Jaramillo, interactuar con él
              if contador == 2
                driver.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", texto_p)
                driver.execute_script("arguments[0].click();", texto_p)
                puts "✔️ Click realizado en el tercer '#{nombre}'."
                break
              end
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
            next
          end
        end


      rescue Selenium::WebDriver::Error::TimeoutError
        puts "❌ ERROR: No se encontró la tabla en el tiempo límite."
      rescue StandardError => e
        puts "❌ ERROR inesperado: #{e.message}"
      ensure
      end




      # Esperar a que se cargue .container-fluid
      container = wait.until { driver.find_element(css: ".rt-tbody") }
      puts "✔️ 'container-big' cargado"

      # Buscar todos los elementos con la clase 'rt-tr-group' dentro de 'rt-tbody'
      rows = container.find_elements(css: ".rt-tr")

      # Verificar si encontramos las filas y mostrar su contenido
      if rows.empty?
        puts "❌ No se encontraron elementos 'rt-tr"
      else
        puts "✔️ Se encontraron #{rows.length} elementos 'rt-tr'."

        rows.each_with_index do |row, index|
          contenido = row.text.strip
          partes = contenido.split("\n") # Dividir el contenido en líneas

          if partes.length == 3
            numero = partes[0] # Primer número
            estado = partes[2] # Estado real (tercer valor)
          else
            numero = partes[0]
            estado = partes[1] # En caso de que solo haya 2 partes
          end

          data << { id: index + 1, numero: numero, estado: estado }
        end
      end

      # Convertir a JSON
      json_data = JSON.pretty_generate(data)

      # Guardar en un archivo JSON
      File.write("tracking_data.json", json_data)

      puts "✅ Datos guardados en tracking_data.json"
      puts data
      pendientes = data.select { |item| item[:estado].include?("En ruta") }

      puts "\n🔍 Pendientes encontrados:"
      puts pendientes

      numeros = pendientes.map { |item| item[:numero] }

      puts "\n📌 Números de los pendientes:"
      puts numeros

      scrollbar_container = wait.until { driver.find_element(css: ".scrollbar-container") }
      puts "✔️ scrollbar-container encontrado"

      # Encontrar el ul dentro del div
      ul_element = scrollbar_container.find_element(css: "ul")
      puts "✔️ ul dentro de scrollbar-container encontrado"

      # Buscar el tercer li dentro del ul
      li_element = ul_element.find_elements(css: "li")[2] # Índice 3 para el cuarto <li> (considerando que el índice empieza en 0)
      puts "✔️ Entrando a operaciones"
      
      # Encontrar el <a> con el atributo data-flag='operations'
      a_element = li_element.find_element(css: "a[data-flag='operations']")
      puts "✔️ <a> con data-flag='operations' encontrado"

      # Aquí puedes hacer clic en el enlace si lo deseas
      # Esperar a que desaparezca el loading-mask antes de intentar hacer clic
      wait.until { driver.find_elements(css: "#loading-mask[style*='display: block']").empty? }
      puts "✔️ Overlay desaparecido, ahora se puede hacer clic en el enlace."

      # Ahora intenta hacer clic en el enlace
      a_element.click
      puts "✔️ Hiciste clic en el enlace con data-flag='operations'"

      # Aumentar el tiempo de espera a 30 segundos para dar más tiempo a la carga
      wait = Selenium::WebDriver::Wait.new(timeout: 30)

      # Esperar a que se cargue el div con clase 'card' después de hacer clic
      card_div = wait.until { driver.find_element(css: ".card") }
      puts "✔️ Div con clase 'card' encontrado"

      # Hacer clic en el div con clase 'card'
      card_div.click
      puts "✔️ Se hizo clic en el div con clase 'card'"

      # Esperar a que se carguen todos los divs con clase 'rt-td' en toda la página
      # Esperar a que se cargue el contenedor rt-tbody
      rt_tbody = wait.until { driver.find_element(css: ".rt-tbody") }
      puts "✔️ Se encontró el contenedor con clase 'rt-tbody'"

      # Buscar todos los divs con clase 'rt-tr-group' dentro de rt-tbody
      rt_tr_groups = rt_tbody.find_elements(css: ".rt-tr-group")
      puts "✔️ Se encontraron #{rt_tr_groups.length} divs con clase 'rt-tr-group'"

      # Verificar si hay al menos dos divs con la clase 'rt-tr-group'
      if rt_tr_groups.length >= 2
        puts "✔️ Se encontró el segundo 'rt-tr-group'."

        # Acceder al segundo 'rt-tr-group' (índice 1 porque es el segundo)
        second_rt_tr_group = rt_tr_groups[3]

        # Imprimir el contenido del segundo 'rt-tr-group'
        puts "🔍 Contenido del 'rt-tr-group':"
        puts second_rt_tr_group.text.strip

        # Esperar a que el 'rt-tr-group' esté visible
        wait.until { driver.find_element(css: ".rt-tr-group") }

        # Esperar un poco antes de buscar el elemento
        sleep(2)

        # Intentar encontrar el elemento y hacer clic en él
        begin
          # Encontrar el <p> dentro del 'rt-tr-group' antes de hacer clic
          p_element = wait.until { driver.find_element(:css, ".rt-tr-group .rt-td .list-item-heading.truncate") }
          wait.until { p_element.displayed? && p_element.enabled? }

          # Hacer scroll hasta el elemento para asegurarse de que no esté oculto
          driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", p_element)

          # Esperar un poco para que desaparezcan elementos superpuestos (como loaders o modales)
          sleep 1
          # Hacer clic en el <p>
          p_element.click
          puts "✔️ Se hizo clic en el <p> con la clase 'list-item-heading truncate'."
        rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
          puts "❌ El elemento ya no es válido. Intentando nuevamente..."
          retry
        end


      else
        puts "❌ No se encontraron suficientes divs con clase 'rt-tr-group'."
      end

    # Esperar a que la página cargue
    wait = Selenium::WebDriver::Wait.new(timeout: 500)

    # Esperar a que el div con la clase 'big__extraItems' sea visible
    big_extra_items_div = wait.until { driver.find_element(css: ".big__extraItems") }

    scan_button = big_extra_items_div.find_element(:css, ".big__scanModal button")

      # Hacer clic en el botón "Escanear"
      wait.until { scan_button.displayed? && scan_button.enabled? }
      driver.execute_script("arguments[0].click();", scan_button)
      puts "✔️ Botón 'Escanear' clickeado con JavaScript."

      # Esperar a que el div con la clase 'position-relative form-group' sea visible
      form_group_div = wait.until { driver.find_element(css: ".modal") }


      # Esperar y encontrar el input y el botón de escanear dentro de la estructura correcta
      input_field = wait.until { driver.find_element(css: "input#tracking_numberV2") }
      scan_button = wait.until { driver.find_element(css: "button.btn-lg.btn-primary") }

      # Iterar sobre la lista de números
      numeros.each do |numero|
      # Asegurarse de que el input sea visible antes de interactuar
      wait.until { input_field.displayed? }

      # Ingresar el número en el input
      input_field.clear
      input_field.send_keys(numero)
      puts "⌨️ Escribiendo número: #{numero}"

      # Esperar a que el botón esté interactuable
      wait.until { scan_button.displayed? && scan_button.enabled? }

      begin
        # Intentar hacer clic en el botón
        scan_button.click
        puts "🔍 Escaneando número..."
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        # Si el botón está bloqueado, usar JavaScript para forzar el clic
        driver.execute_script("arguments[0].click();", scan_button)
        puts "🔍 Escaneando número con JavaScript..."
      end

      # Esperar a que aparezca el mensaje correspondiente al número actual
      begin
        mensaje = wait.until do
          mensaje_element = driver.find_element(css: "div[style*='max-height: 350px;'] p")
          mensaje_element.text.include?(numero) ? mensaje_element : nil
        end
        puts "📢 Mensaje mostrado: #{mensaje.text}"
      rescue Selenium::WebDriver::Error::TimeoutError
        puts "⚠️ No se encontró un mensaje de respuesta para #{numero}."
      end

      # Pequeña pausa antes de continuar con el siguiente número
      sleep(2)
    end

    begin
      # Esperar hasta que el botón 'Ingresar' sea visible
      ingresar_button = wait.until { driver.find_element(xpath: "//button[contains(@class, 'btn-lg') and contains(@class, 'btn-outline-secondary')]") }

      # Verificar si el botón está habilitado y visible
      if ingresar_button.displayed? && ingresar_button.enabled?
        ingresar_button.click
        puts "✔️ Se hizo clic en el botón 'Ingresar'."
      else
        puts "❌ El botón 'Ingresar' no está disponible para hacer clic."
      end

    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "❌ Botón 'Ingresar' no encontrado."
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError
      driver.execute_script("arguments[0].click();", ingresar_button)
      puts "✔️ Botón 'Ingresar' clickeado usando JavaScript."
    end

    # Esperar a que se carguen los números después del clic
    sleep 2

    # Esperar a que el contenedor con la clase 'd-flex justify-content-between' sea visible
    wait.until { driver.find_element(xpath: "//div[contains(@class, 'd-flex') and contains(@class, 'justify-content-between')]").displayed? }

    puts "✔️ El contenedor de 'Última milla' está visible. Los paquetes han sido agregados."


    rescue Selenium::WebDriver::Error::TimeoutError
      puts "❌ Tiempo de espera agotado, el contenido no cargó."
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts "❌ No se encontró el elemento: #{e.message}"
    ensure
      driver.quit
    end
  end
end
