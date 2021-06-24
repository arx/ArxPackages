
; English text for the Arx Libertatis Windows installer

${LangFileString} SINGLE_INSTANCE "$(^Name) Setup is already running!"

${LangFileString} ARX_WINDOWS_XP_SP2 "Arx Libertatis requires Windows XP Service Pack 2 or later."

${LangFileString} ARX_WINDOWS_UCRT "Arx Libertatis requires the Windows Universal C Runtime (UCRT)."
${LangFileString} ARX_WINDOWS_UCRT_XP "For Windows XP you can get it by installing the Visual C++ Redistributable for Visual Studio 2015 or later:"
${LangFileString} ARX_WINDOWS_UCRT_VISTA "For Windows Vista or newer you should have gotten it as a Windows update."

${LangFileString} ARX_TITLE_SUFFIX "Setup"

${LangFileString} ARX_DEVELOPMENT_SNAPSHOT "Development Snapshot"
${LangFileString} ARX_RELEASE_CANDIDATE "Release Candidate"
${LangFileString} ARX_SNAPSHOT_WARNING "This build of $(^Name) is a development snapshot that has not been tested extensiviely and may contain both known and unknown bugs. If you encounter any issues, please report them here:"

${LangFileString} ARX_FATALIS_LOCATION_PAGE_TITLE "Specify Arx Fatalis Location"
${LangFileString} ARX_FATALIS_LOCATION_PAGE_SUBTITLE "Specify the location of the Arx Fatalis data"
${LangFileString} ARX_FATALIS_LOCATION_PAGE_DESCRIPTION "In order to play $(^Name), you need the original data from Arx Fatalis.$\nIf you do not have Arx Fatalis, see ${ARX_DATA_URL} for where to get it.$\nYou can also play using the demo data.$\n$\nPlease specify the directory of the Arx Fatalis installation where *.pak files can be found."
${LangFileString} ARX_FATALIS_LOCATION_LABEL "Arx Fatalis Location"
${LangFileString} ARX_FATALIS_LOCATION_BROWSE_TITLE "Select Arx Fatalis location:"
${LangFileString} ARX_FATALIS_LOCATION_WAIT "Identifying Arx Fatalis data..."
${LangFileString} ARX_FATALIS_LOCATION_EMPTY "Could not find any Arx Fatalis data!"
${LangFileString} ARX_FATALIS_LOCATION_EMPTY_CONTINUE "Without specifying an Arx Fatalis data location you will have to manually copy the .pak files to your $(^Name) install before you will be able to play.$\n$\nContinue with no Arx Fatalis data location?"
${LangFileString} ARX_FATALIS_LOCATION_NODIR "Selected directory does not exist!"
${LangFileString} ARX_FATALIS_LOCATION_NODATA "Could not find any Arx Fatalis data at the selected location!"
${LangFileString} ARX_FATALIS_LOCATION_FOUND "Found Arx Fatalis data:"
${LangFileString} ARX_FATALIS_LOCATION_UNKNOWN "Unknown version"
${LangFileString} ARX_FATALIS_LOCATION_RETAIL "Full game"
${LangFileString} ARX_FATALIS_LOCATION_DEMO "Demo"
${LangFileString} ARX_FATALIS_LOCATION_GOG "GOG"
${LangFileString} ARX_FATALIS_LOCATION_STEAM "Steam"
${LangFileString} ARX_FATALIS_LOCATION_BETHESDA "Bethesda.net"
${LangFileString} ARX_FATALIS_LOCATION_WINDOWS "Microsoft Store"
${LangFileString} ARX_FATALIS_LOCATION_UNPATCHED "Missing 1.21 patch!"
${LangFileString} ARX_FATALIS_LOCATION_UNPATCHED_CONTINUE "It is strongly recommended to patch Arx Fatalis to version 1.21 before installing $(^Name)!$\n$\nYou can get the patch here:$\n${ARX_PATCH_URL}$\n$\nContinue with unpatched Arx Fatalis data?"

${LangFileString} ARX_PATCH_INSTALL "Patch existing Arx Fatalis install"
${LangFileString} ARX_PATCH_INSTALL_DESC "Play using Arx Libertatis when you launch Arx Fatalis. (Recommended)"

${LangFileString} ARX_SEPARATE_INSTALL "Create a separate Arx Libertatis install"
${LangFileString} ARX_SEPARATE_INSTALL_DESC "Only use Arx Libertatis when launched through its own shortcut. (Not Recommended)"

${LangFileString} ARX_INSTALL_STATUS "Installing Arx Libertatis..."

${LangFileString} ARX_KEEP_DATA_STATUS "Saving copied Arx Fatalis data..."

${LangFileString} ARX_COPY_DATA "Copy Arx Fatalis data"
${LangFileString} ARX_COPY_DATA_DESC "Copy all .pak files so that Arx Libertatis will continue to work after you uninstall Arx Fatalis."
${LangFileString} ARX_COPY_DATA_STATUS "Copying Arx Fatalis data..."
${LangFileString} ARX_COPY_DATA_DIR "Source location:"
${LangFileString} ARX_COPY_DATA_FILE "Copying"

${LangFileString} ARX_CREATE_SHORTCUT_STATUS "Creating Arx Libertatis shortcuts..."

${LangFileString} ARX_CREATE_DESKTOP_ICON "Create a desktop icon"
${LangFileString} ARX_CREATE_DESKTOP_ICON_DESC "Create a shortcut on your desktop to run Arx Libertatis."

${LangFileString} ARX_CREATE_QUICKLAUNCH_ICON "Create a Quick Launch icon"
${LangFileString} ARX_CREATE_QUICKLAUNCH_ICON_DESC "Create a shortcut in your Quick Launch bar to run Arx Libertatis."

${LangFileString} ARX_CLEANUP_STATUS "Removing old files..."

${LangFileString} ARX_VERIFY_DATA_STATUS "Verifying Arx Fatalis data..."
${LangFileString} ARX_VERIFY_DATA_DIR "Data location:"
${LangFileString} ARX_VERIFY_DATA_FILE "Verifying"
${LangFileString} ARX_VERIFY_DATA_UNKNOWN "Unexpected checksum:"
${LangFileString} ARX_VERIFY_DATA_UNPATCHED "Checksum matches unpatched version:"
${LangFileString} ARX_VERIFY_DATA_VALID "Checksum is valid:"
${LangFileString} ARX_VERIFY_DATA_VALID_RETAIL "Checksum is valid for full game:"
${LangFileString} ARX_VERIFY_DATA_VALID_DEMO "Checksum is valid for demo:"
${LangFileString} ARX_VERIFY_DATA_MISSING "Missing:"
${LangFileString} ARX_VERIFY_DATA_MIXED "Found mixed Demo and Full version data!"
${LangFileString} ARX_VERIFY_DATA_FAILED "Found problems with your Arx Fatalis data!"
${LangFileString} ARX_VERIFY_DATA_SUCCESS "Data successfully verified."
${LangFileString} ARX_VERIFY_DAYA_PATCH_STEAM "Right click Arx Fatalis in your Steam library, choose 'Properties' and go to 'LOCAL FILES' and click 'Verify integrity of game files'."
${LangFileString} ARX_VERIFY_DAYA_PATCH_BETHESDA "Go to Arx Libertatis in the Bethesda.net Launcher, click 'Game Options' and choose 'Scan and Repair'."
${LangFileString} ARX_VERIFY_DAYA_PATCH_WINDOWS "Go to Arx Fatalis (PC) in the Windows 'Add or remove programs' dialog, choose 'Advanced options' and there click 'Repair'."
${LangFileString} ARX_VERIFY_DATA_PATCH "Please install the 1.21 patch: $(ARX_PATCH_URL)"
${LangFileString} ARX_VERIFY_DATA_REINSTALL "Afterwards, run the $(^Name) Setup again!"
${LangFileString} ARX_VERIFY_DATA_REPORT "If you believe your Arx Fatalis data is valid, please report a bug with the full output:"
${LangFileString} ARX_COPY_DETAILS "You can right click here and choose '$(^CopyDetails)'."

${LangFileString} UNINSTALL_LOG "Could not open ${UninstallLog}!"
