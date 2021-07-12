
; Spanish text for the Arx Libertatis Windows installer

${LangFileString} ^tera "T"

${LangFileString} SINGLE_INSTANCE "$(^Name) ¡El programa de instalación ya se está ejecutando!"

${LangFileString} ABORT_RETRY_IGNORE "Haga clic en abortar para detener la instalación,$\nReintentar para volver a intentar escribir el archivo, u$\nOmitir para ignorar este archivo."
${LangFileString} SPACE_FREED "Espacio necesario: "
${LangFileString} SPACE_LOW_CONTINUE "La instalación requiere $1 de espacio libre en disco pero sólo hay disponible $2 en la ubicación de la instalación:$\n$\n$0$\n$\n¿Continuar de todas formas?"

${LangFileString} ARX_WINDOWS_XP_SP2 "$(^Name) requiere Windows XP Service Pack 2 o superior."

${LangFileString} ARX_WINDOWS_UCRT "$(^Name) requiere Windows Universal C Runtime (UCRT)."
${LangFileString} ARX_WINDOWS_UCRT_XP "Para Windows XP puedes obtenerlo al instalar Visual C++ Redistributable para Visual Studio 2015 o superior:"
${LangFileString} ARX_WINDOWS_UCRT_VISTA "Para Windows Vista o superior debes haberlo obtenido en una actualización de Windows."

${LangFileString} ARX_TITLE_SUFFIX "Instalador"

${LangFileString} ARX_DEVELOPMENT_SNAPSHOT "Versión en desarrollo"
${LangFileString} ARX_RELEASE_CANDIDATE "Candidata para el lanzamiento"
${LangFileString} ARX_SNAPSHOT_WARNING "Esta compilación de $(^Name) es una versión en desarrollo la cual no ha sido probada extensamente y podría contener tanto errores conocidos como desconocidos. Si encuentras cualquier problema, por favor repórtalo aquí:"

${LangFileString} ARX_FATALIS_LOCATION_PAGE_TITLE "Especificar la ubicación de Arx Fatalis"
${LangFileString} ARX_FATALIS_LOCATION_PAGE_SUBTITLE "Especifica la ubicaión de los archivos de Arx Fatalis"
${LangFileString} ARX_FATALIS_LOCATION_PAGE_DESCRIPTION "Para poder jugar $(^Name), necesitas los archivos de Arx Fatalis.$\nSi no tienes Arx Fatalis, visita ${ARX_DATA_URL} para ver dónde obtenerlo.$\nTambién puedes jugar usando los archivos de la demo."
${LangFileString} ARX_FATALIS_LOCATION_PAGE_DESCRIPTION_PATCH "Selecciona la carpeta de instalación de Arx Fatalis que desees parchear."
${LangFileString} ARX_FATALIS_LOCATION_PAGE_DESCRIPTION_COPY "Selecciona la carpeta de instalación de Arx Fatalis de la cual desees copiar los archivos."
${LangFileString} ARX_FATALIS_LOCATION_PAGE_DESCRIPTION_PAK "Por favor especifica el directorio de la carpeta de instalación de Arx Fatalis donde se encuentren los archivos *.pak."
${LangFileString} ARX_FATALIS_LOCATION_KEEP "&Conservar los archivos existentes en el directorio de $(^Name)."
${LangFileString} ARX_FATALIS_LOCATION_LABEL "Ubicación de Arx Fatalis"
${LangFileString} ARX_FATALIS_LOCATION_BROWSE_TITLE "Selecciona la ubicación de Arx Fatalis:"
${LangFileString} ARX_FATALIS_LOCATION_WAIT "Identificando los archivos de Arx Fatalis..."
${LangFileString} ARX_FATALIS_LOCATION_EMPTY "¡No se pudo encontrar ningún archivo de Arx Fatalis!"
${LangFileString} ARX_FATALIS_LOCATION_EMPTY_CONTINUE "Al no especificar una ubicación para los archivos de Arx Fatalis, tendrás que copiar manualmente los archivos .pak en la carpeta de instalación de $(^Name) antes de poder jugar.$\n$\n¿Continuar sin una ubicación de Arx Fatalis?"
${LangFileString} ARX_FATALIS_LOCATION_NODIR "¡El directorio seleccionado no existe!"
${LangFileString} ARX_FATALIS_LOCATION_NODATA "¡No se ha podido encontrar ningún archivo de Arx Fatalis en la ubicación seleccionada!"
${LangFileString} ARX_FATALIS_LOCATION_FOUND "Archivos de Arx Fatalis encontrados:"
${LangFileString} ARX_FATALIS_LOCATION_UNKNOWN "Versión desconocida"
${LangFileString} ARX_FATALIS_LOCATION_RETAIL "Juego completo"
${LangFileString} ARX_FATALIS_LOCATION_DEMO "Demo"
${LangFileString} ARX_FATALIS_LOCATION_GOG "GOG"
${LangFileString} ARX_FATALIS_LOCATION_STEAM "Steam"
${LangFileString} ARX_FATALIS_LOCATION_BETHESDA "Bethesda.net"
${LangFileString} ARX_FATALIS_LOCATION_WINDOWS "Microsoft Store"
${LangFileString} ARX_FATALIS_LOCATION_UNPATCHED "¡Falta el parche 1.21!"
${LangFileString} ARX_FATALIS_LOCATION_UNPATCHED_CONTINUE "Se recomienda encarecidamente parchear Arx Fatalis a la versión 1.21 antes de instalar $(^Name)!$\n$\nPuedes obtener el parche aquí:$\n${ARX_PATCH_URL}$\n$\n¿Continuar con archivos de Arx Fatalis sin parchear?"

${LangFileString} ARX_MODIFY_INSTALL "Modificar la instalación de $(^Name)"
${LangFileString} ARX_REPAIR_INSTALL "Reparar la instalación de $(^Name)"
${LangFileString} ARX_UPDATE_INSTALL "Actualizar $(^Name) a la versión <?= $version ?>"
${LangFileString} ARX_UNINSTALL "Desinstalar $(^Name)"
${LangFileString} ARX_EXISTING_INSTALL "Instalación de $(^Name) encontrada:"

${LangFileString} ARX_PATCH_INSTALL "Parchear instalación existente de Arx Fatalis"
${LangFileString} ARX_PATCH_INSTALL_DESC "Jugar usando $(^Name) cuando ejecutes Arx Fatalis. (Recomendado)"

${LangFileString} ARX_SEPARATE_INSTALL "Crear una instalación separada de $(^Name)"
${LangFileString} ARX_SEPARATE_INSTALL_DESC "Sólo usar $(^Name) cuando se ejecute a través de su propio acceso directo. (No Recomendado)"
${LangFileString} ARX_SEPARATE_INSTALL_CONTINUE "Has elegido crear una instalación separada de $(^Name) pero la ubicación de la instalación ya contiene archivos de Arx Fatalis:$\n$\n$0$\n$\n¿Continuar con esta ubicación?"

${LangFileString} ARX_INSTALL_STATUS "Instalando $(^Name)..."

${LangFileString} ARX_KEEP_DATA "Conservar los archivos copiados de Arx Fatalis"
${LangFileString} ARX_KEEP_DATA_STATUS "Guardando los archivos copiados de Arx Fatalis..."

${LangFileString} ARX_COPY_DATA "Copiar los archivos de Arx Fatalis"
${LangFileString} ARX_COPY_DATA_DESC "Copiar todos los archivos .pak, así $(^Name) seguirá funcionando después de que desinstales Arx Fatalis."
${LangFileString} ARX_COPY_DATA_STATUS "Copiando archivos de Arx Fatalis..."
${LangFileString} ARX_COPY_DATA_DIR "Ubicación de origen:"
${LangFileString} ARX_COPY_DATA_FILE "Copiar"
${LangFileString} ARX_COPY_DATA_FILE_ERROR "Ha habido un error al copiar los archivos de Arx Fatalis:$\n$\nDe: $0$\nA: $1"

${LangFileString} ARX_CREATE_SHORTCUT_STATUS "Creando accesos directos de $(^Name)..."

${LangFileString} ARX_CREATE_DESKTOP_ICON "Crear un icono en el escritorio"
${LangFileString} ARX_CREATE_DESKTOP_ICON_DESC "Crear un acceso directo en el escritorio para ejecutar $(^Name)."

${LangFileString} ARX_CREATE_QUICKLAUNCH_ICON "Crear un icono de Acceso Rápido"
${LangFileString} ARX_CREATE_QUICKLAUNCH_ICON_DESC "Crear un acceso directo en la barra de Acceso Rápido para ejecutar $(^Name)."

${LangFileString} ARX_CLEANUP_STATUS "Eliminando archivos antiguos..."

${LangFileString} ARX_VERIFY_DATA_STATUS "Verificando archivos de Arx Fatalis..."
${LangFileString} ARX_VERIFY_DATA_DIR "Ubicación de los archivos:"
${LangFileString} ARX_VERIFY_DATA_FILE "Verificando"
${LangFileString} ARX_VERIFY_DATA_UNKNOWN "Verificación inesperada:"
${LangFileString} ARX_VERIFY_DATA_UNPATCHED "La verificación coincide con la versión sin parchear:"
${LangFileString} ARX_VERIFY_DATA_VALID "La verificación es válida:"
${LangFileString} ARX_VERIFY_DATA_VALID_RETAIL "La verificación es válida para el juego completo:"
${LangFileString} ARX_VERIFY_DATA_VALID_DEMO "La verificación es válida para la demo:"
${LangFileString} ARX_VERIFY_DATA_MISSING "Falta:"
${LangFileString} ARX_VERIFY_DATA_MIXED "¡Se encontraron archivos mezclados de la demo y la versión completa!"
${LangFileString} ARX_VERIFY_DATA_FAILED "¡Se encontraron problemas con tus archivos de Arx Fatalis!"
${LangFileString} ARX_VERIFY_DATA_SUCCESS "Archivos verificados con éxito."
${LangFileString} ARX_VERIFY_DATA_PATCH_STEAM "Has clic derecho en Arx Fatalis en tu biblioteca de Steam, elige 'Propiedades', dirígete a 'ARCHIVOS LOCALES' y has clic en 'Verificar integridad de los archivos'."
${LangFileString} ARX_VERIFY_DATA_PATCH_BETHESDA "Dirígete a Arx Fatalis en el launcher de Bethesda.net, has clic en 'Opciones juego' y elige 'Escanear y Reparar'."
${LangFileString} ARX_VERIFY_DATA_PATCH_WINDOWS "Dirígete a Arx Fatalis (PC) en el cuadro de diálogo de windows 'Agregar o quitar programas', elige 'Opciones avanzadas' y ahí has clic en 'Reparar'."
${LangFileString} ARX_VERIFY_DATA_PATCH_REINSTALL "Por favor (re-)instala Arx Fatalis."
${LangFileString} ARX_VERIFY_DATA_PATCH "Por favor (re-)instala el parche 1.21:"
${LangFileString} ARX_VERIFY_DATA_REINSTALL "Luego, ejecuta el programa de instalación de $(^Name) de nuevo"
${LangFileString} ARX_VERIFY_DATA_REPORT "Si crees que tus archivos de Arx Fatalis son válidos, por favor reporta el error con la información completa:"
${LangFileString} ARX_COPY_DETAILS "Puedes hacer clic derecho aquí y elegir '$(^CopyDetails)'."

${LangFileString} UNINSTALL_LOG "No se ha podido abrir ${UninstallLog}!"
${LangFileString} UNINSTALL_ERROR "Ha habido un error al quitar un archivo o directorio:$\n$\n$0"
${LangFileString} UNINSTALL_NOT_EMPTY "¡El directorio de instalación no está vacío! ¿Eliminar de todas formas?"
${LangFileString} UNINSTALL_REPAIR "$(^Name) ha sido eliminado de la carpeta de instalación de Arx Fatalis pero puede que necesites repararla:"
