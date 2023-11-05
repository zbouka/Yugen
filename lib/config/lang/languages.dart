import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

/// Class for the string map in all the available languages
class Language extends Translations {
  final BaseLanguage esLanguage;
  final BaseLanguage enLanguage;

  Language({required this.esLanguage, required this.enLanguage});

  @override
  Map<String, Map<String, String>> get keys => {
        'es': esLanguage.language,
        'en': enLanguage.language,
      };
}

abstract class BaseLanguage {
  Map<String, String> get language;
}

class EsLanguage implements BaseLanguage {
  @override
  Map<String, String> get language => {
        'welcome': 'Bienvenid@ a Yugen',
        'welcomeDescription':
            'Te damos la bienvenida a Yugen, una app móvil donde podrás ver un amplio catálogo de manga/anime, y otras muchas funciones más .',
        'getStarted': 'Comenzar',
        'choose': 'Elige tu idioma',
        'language': "Idioma",
        "spanish": "Español",
        "english": "Inglés",
        'welcome1': 'Bienvenid@ de nuevo',
        'create1': 'Crear cuenta',
        'password': 'Contraseña',
        'PassNotSame': 'Las contraseñas no coinciden',
        'password2': 'Confirma la contraseña',
        'emailIsRequired': 'El email es requerido',
        'validEmail': 'Introduzca un email válido',
        'PassIsRequired': 'Introduzca una contraseña de 8 o más caracteres',
        'forgotPass': '¿Has olvidado la contraseña?',
        'haveAccount': '¿Ya tienes una cuenta?',
        "noElement":
            "El elemento buscado no se encuentra en nuestra base de datos",
        'login': 'Iniciar sesión',
        'register': 'Registrarse',
        'googleRegister': 'Registrarse con Google',
        'googleLogin': 'Iniciar sesión con Google',
        'notAccount': '¿No tienes una cuenta?',
        'signUp': 'Registrarse',
        'signedIn': 'Conectado',
        'loggedIn': 'Has iniciado sesión con el e-mail @email',
        'userName': 'Nombre de usuario',
        'UserNameIsRequired': 'El nombre de usuario es requerido',
        'userIsValid': 'El nombre de usuario ya esta siendo usado',
        'valid': 'Correcto',
        'userChanged': 'El nombre de usuario se ha actualizado correctamente',
        "verification": "Verificación",
        'sendEmail':
            'Hemos enviado un correo al e-mail @email para confirmar el registro',
        'userError':
            'Usuario no encontrado, revisa tu correo electrónico o registrese',
        'emailInUse':
            'Este email ya se encuentra registrado, por favor inicie sesión',
        'passwordIsWrong': 'La contraseña es incorrecta',
        'sendVerificationEmail':
            'Un email de verificación ha sido enviado a su cuenta',
        'confirmAccount': 'CONFIRMAR CUENTA',
        'verificationEmail': 'EMAIL DE VERIFICACIÓN',
        'tooEmails': 'Debe de esperar un minuto para reenviar el email',
        'reset': 'Restablecer',
        'reset2': 'contraseña',
        'username1': 'Cambiar',
        'username2': 'nombre',
        'succeed': 'COMPLETADO',
        'success': 'Completado',
        'succeedMessage':
            'Un correo para restablecer la contraseña ha sido enviado a su correo',
        'messageError': 'El usuario relacionado con ese email no existe',
        'returnToLogin': '¿Volver al login?',
        'return': 'Volver',
        'favorites': 'Favoritos',
        'settings': 'Ajustes',
        'ReadL': 'Leer menos',
        'ReadM': 'Leer más',
        'status': 'Estado: ',
        'year': 'Año de publicación: ',
        'numberC': 'Episodios: ',
        'rating': 'Calificación: ',
        'downloading': 'Descargando',
        'cancel': 'Cancelar',
        'saveToFolder': 'Descargar manga',
        'saveFile': 'Guardar en esta carpeta',
        'chapter': 'Capítulo',
        'Description': 'Descripción',
        'Chapters': 'Capítulos',
        'Comments': 'Comentarios',
        'commentHere': 'Comenta aqui...',
        'emailNotFound':
            'El email introducido no existe, compruebe que este bien escrito o use otro',
        'send': 'Enviar',
        'confirm': 'Confirmar',
        'confirmDelete': 'Confirmar eliminación',
        'deleteText': '¿Estás seguro de que quieres eliminar este comentario?',
        'showMore': 'Mostrar mas',
        'showLess': 'Mostrar menos',
        'fileExists': 'El capitulo seleccionado ya se encuentra descargado',
        'latestReleased': 'Últimos lanzamientos',
        'action': 'Acción',
        'modify': 'Editar perfil',
        'tapToChange': 'Presiona para cambiar tus datos',
        'changeLanguage': 'Cambiar el idioma de la aplicación',
        'changeMode': 'Cambiar tema',
        'changeTheme': 'Cambia el tema actual',
        'about': 'Acerca de',
        'learnMore': 'Presiona para conocer mas de Yugen',
        'signOut': 'Cerrar sesión',
        'account': 'Cuenta',
        'deleteAccount': 'Eliminar cuenta',
        'wallpaper': 'El fondo de pantalla se ha establecido correctamente',
        'save': 'Guardar',
        'displayName': 'Nombre de usuario',
        'confirmDeleteAccount':
            'Al realizar esta acción se eliminara toda su informacion de manera no reversible. ¿Desea continuar?',
        'emailNotVerified':
            'El email no esta verificado, asi que se ha enviado un correo de verificacion a la cuenta introducida',
        'notReceivedEmail': '¿Reenviar email de confirmación?',
        'resendEmail': 'Reenviar',
        'errorUpdateProfileEmail':
            'El email introducido, ya esta siendo usado pruebe con otro',
        'correct': 'Correcto',
        'updateProfile':
            'Perfil actualizado con éxito, cierre sesión y vuelva a iniciar sesión para aplicar los cambios. En caso de haber cambiado el email se le ha enviado un email para confirmarlo',
        'invalidMail': 'El email introducido no es valido, pruebe con otro',
        'recommended': 'Recomendados',
        'descriptionYugen':
            'Yugen es una aplicación donde puedes disfrutar del contenido más reciente de anime y manga de forma gratuita, sin anuncios. Tiene la opción de transmitir o descargar episodios individuales o series completas según sus preferencias. Además, puede guardar sus títulos favoritos en una lista personal de favoritos, lo que le permitirá acceder a ellos fácilmente en cualquier momento.',
        'descriptionYugen2':
            'También contamos con una sección de noticias donde podrás ver las últimas novedades relacionadas con manga, anime o incluso más. Además, te ofrecemos los mejores fondos de pantalla para tu teléfono. La animación de la pantalla de bienvenida fue creada por Mahendra Bhunwal, al igual que Camila Massetti creó la animación splash inicial. Por último, quiero señalar que no poseemos los derechos intelectuales de ninguno de los materiales de esta aplicación y NO alojamos ningún material, ya que todo es proporcionado por páginas web de terceros. Esos derechos pertenecen a los creadores originales de los artículos.',
        "noComments": "No hay comentarios",
        "noElements":
            'En estos momentos estamos haciendo un mantenimiento de la base de datos, disculpe las molestias.',
        "news": "Noticias",
        "mystery": "Misterio",
        "chapterAlredyExists":
            "El capitulo ya existe, por lo que no se descargara el capitulo @numCap",
        "animelist": 'Las noticias son proveidas por MyAnimeList',
        "xtrafondo": "Los wallpapers son proveidos por Xtrafondos",
        "notFound": "¡No se ha encontrado ningun resultado!",
        "report":
            "Este artículo ya no está disponible. ¿Quieres enviar un informe?. Simplemente recopila los datos de error y no se enviará información personal.",
        "error": "Error",
        "detailError":
            "Ha habido un problema con la app. ¿Quiere enviar un reporte para analizar el problema?",
        "successWallpaper": "😊 El fondo de pantalla se aplicó correctamente",
        "errorWallpaper": "😢 El fondo de pantalla no se pudo aplicar.",
        "errorScreen": "¡Ha ocurrido un error!",
        "noRecommended":
            "No hay recomendaciones en este feed por ahora, pero puede ser la primera persona en crear la primera 😊",
        "noWallpapers": "En este momento no hay ningun wallpaper disponible",
        "noFavorites": "No hay ningun elemento en Favoritos",
        "accountDeleted": "Su cuenta ha sido eliminada de forma correcta",
        "videoNotValid":
            "Este video no se encuentra disponible en estos momentos, ¿Desea enviar un email para notificar del error?",
        "setWallpaper": "Seleccione en que pantalla desea aplicar el fondo",
        "dynamic":
            "Verifique si ha activado el Color dinámico, esto puede causar que la aplicación se reinicie de manera forzada.",
        "warningDynamic":
            "Este es un aviso para los usuarios que tengan android 12 o superior",
        "noNews":
            "Ha ocurrido un error con las noticias y no se pueden mostrar",
        "noInternet": "No hay ninguna conexión a Internet en este momento",
        "notAvailable":
            "El capitúlo @numCap ya no se encuentra disponible. ¿Quiere reportarlo?",
        "invalidProvider":
            "Este correo electronico esta registrado con un proveedor externo, asi que no podemos cambiar la contraseña",
        "noPassword":
            "Esta cuenta de correo esta registrada con un proveedor externo, le redirigemos a su proveedor para iniciar sesion",
        "rememberLogin": "Recordar credenciales",
        "googleAccount":
            "Esta cuenta esta vinculada a google, utilice el botón de inicio de sesión de Google en su lugar."
      };
}

class EnLanguage implements BaseLanguage {
  @override
  Map<String, String> get language => {
        'welcome': 'Welcome to Yugen',
        'welcomeDescription':
            'We welcome you to Yugen, a mobile app where you can see a wide catalog of manga/anime, and many other functions',
        'getStarted': 'Get Started',
        'choose': 'Choose your language',
        'language': "Language",
        "spanish": "Spanish",
        "english": "English",
        'welcome1': 'Welcome back',
        'create1': 'Create account',
        'password': 'Password',
        'password2': 'Confirm the password',
        'PassNotSame': 'Passwords do not match',
        'emailIsRequired': 'Email is missing',
        'PassIsRequired': 'Enter a password of 8 or more characters ',
        'forgotPass': 'Forgot your password?',
        "noFavorites": "There aren´t any element in Favorites",
        "noElement": "The searched item is not in our database",
        'login': 'Login',
        'register': 'Sign up',
        'googleRegister': 'Sign up with Google',
        'googleLogin': 'Login with Google',
        'notAccount': 'Don´t have an account?',
        'haveAccount': 'Already have an account?',
        'signUp': 'Sign up',
        'validEmail': 'Enter a valid email',
        'UserNameIsRequired': 'Username is required',
        'valid': 'Correct',
        'userChanged': 'Username has been successfully changed',
        'userIsValid': 'This username is alredy taken',
        'signedIn': 'Logged in',
        'loggedIn': 'You are logged in with the email @email',
        'userName': 'Username',
        'verification': "Verification",
        'sendEmail':
            'We sent a verification email to @email to proceed with the sign up',
        'userError': 'User not found, check your email or sign up',
        'emailInUse': 'Email already in use please login',
        'passwordIsWrong': 'Password is wrong',
        'sendVerificationEmail': 'A verification email has sent to your email',
        'confirmAccount': 'CONFIRM ACCOUNT',
        'verificationEmail': 'VERIFICATION EMAIL',
        'tooEmails': 'Wait a minute to resend the email',
        'reset': 'Reset',
        'reset2': 'password',
        'username1': 'Change',
        'username2': 'username',
        'succeed': 'Succeed',
        'success': 'Success',
        'succeedMessage': 'An email for reseting has been sent to your email',
        'messageError': 'The user related to this email does not exist',
        'returnToLogin': 'Return to login?',
        'return': 'Return',
        'messageGoogleLogin': '',
        'favorites': 'Favorites',
        'settings': 'Settings',
        'ReadL': 'Read less',
        'ReadM': 'Read more',
        'status': 'Status: ',
        'year': 'Release date: ',
        'numberC': 'Chapters: ',
        'rating': 'Rating: ',
        'downloading': 'Downloading',
        'cancel': 'Cancel',
        'saveToFolder': 'Download manga',
        'saveFile': 'Save in this folder',
        'chapter': 'Chapter',
        'Description': 'Description',
        'Chapters': 'Chapters',
        'Comments': 'Comments',
        'commentHere': 'Comment here',
        'emailNotFound':
            'Email does not exist, check if is correct or use another',
        'send': 'Send',
        'confirm': 'Confirm',
        'confirmDelete': 'Confirm delete',
        'deleteText': 'Are you sure you want to delete this comment?',
        'showMore': 'Show more',
        'showLess': 'Show less',
        'fileExists': 'The selected chapter has already been downloaded',
        'latestReleased': 'Latest Released',
        'action': 'Action',
        'modify': 'Edit profile',
        'tapToChange': 'Tap to change your profile data',
        'changeLanguage': 'Change the app language',
        'changeMode': 'Change theme',
        'changeTheme': 'Change the current theme',
        'about': 'About',
        'learnMore': 'Press to know more about Yugen',
        'signOut': 'Sign out',
        'account': 'Account',
        'deleteAccount': 'Delete account',
        'wallpaper': 'The wallpaper has been set successfully',
        'save': 'Save',
        'displayName': 'Username',
        'confirmDeleteAccount':
            'Performing this action deletes all your information non-reversibly. Do you wish to continue?',
        'emailNotVerified':
            'The email is not verified, so a confirmation email has been send to your account',
        'notReceivedEmail': 'Resend verification email?',
        'resendEmail': 'Resend email',
        'errorUpdateProfileEmail':
            'The email is alredy on use, please try another',
        'correct': 'Correct',
        'updateProfile':
            'Profile updated successfully, please log out and log back in to apply changes. If you have changed the email, an email has been sent to confirm it.',
        'invalidMail': 'The email entered is not valid, please try another',
        'recommended': 'Recommended',
        'descriptionYugen':
            "Yugen is an app where you can enjoy the latest anime and manga content for free, without any ads. You have the option to either stream or download individual episodes or complete series according to your preference. Additionally, you can save your favorite titles to a personal favorites list, allowing you to easily access them at any time.",
        "descriptionYugen2":
            'We also have a news section where you can see the latest news related of manga, anime or even more. Moreover, we are offering you with the best wallpapers for your phone. The splash screen animation has been created by Mahendra Bhunwal, just like the initial splash animation was created by Camila Massetti. Lastly, I want to point out that we don´t own the intellectual rights to any of the materials in this app, and we DON´T host any material since all is provided by third-party webpages. Those rights belong to the original creators of the items.',
        "noComments": "No comments",
        "noElements":
            'We are currently doing database maintenance, sorry for the inconvenience.',
        "news": "News",
        "mystery": "Mystery",
        "chapterAlredyExists":
            "This chapter already exist, so the chapter @numCap won't be downloaded",
        "animelist": 'News provided by MyAnimeList',
        "notFound": "Item not found",
        "report":
            "This item is no longer available. Would you like to send a report?. It just collects the error data and no personal information will be send",
        "error": "Error",
        "detailError":
            "There has been an error on the app. Would you like to send a report to analyze the error?",
        "successWallpaper": "😊 Wallpaper applied successfully.",
        "errorWallpaper": "😢 Wallpaper could not be applied.",
        "errorScreen": "Error Occurred!",
        "noRecommended":
            "There are no recommended in this feed for now, be free to be first one to create one😊",
        "noWallpapers":
            "In this moment there aren´t any available wallpaper at this time",
        "accountDeleted": "Your account has been successfully deleted",
        "videoNotValid":
            "This video is currently unaivalable, feel free to send an email to notify about this error",
        "xtrafondo": "The wallpapers are being provided by Xtrafondos",
        "setWallpaper": "Select on which screen to apply the wallpaper",
        "dynamic":
            "Please check if you have activated Dynamic Color, this may cause a restart on the app forcefully",
        "warningDynamic": "Warning for users who uses android 12 or superior",
        "noNews":
            "There has been an error and it wont be possible to display any news",
        "noInternet": "There is no Internet connection in this moment",
        "notAvailable":
            "The chapter @numCap is no longer available, would you like to report it?",
        "invalidProvider":
            "This email is from an external provider, so we can´t change the password",
        "noPassword":
            "This email is from an external provider, so we´ll redirect you to the provider login page",
        "rememberLogin": "Remember credentials",
        "googleAccount":
            "This account is linked to google, use the google login button instead"
      };
}
