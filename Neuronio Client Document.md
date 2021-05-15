# Neuronio Client

Neuronio is An Application for both **android** and **ios** devices that help to improve the connection between people and doctors. This app is written in **dart** with **flutter** framework to support different devices at the same time and also flutter is a good choice if you want a better performance.


## Project Code Structure and Architecture
 - [/blocs](#blocs)
 - [/constants](#constants)
 - [/models](#models)
    - [AgoraChannelEntity](#/models/#AgoraChannelEntity)
    - [DoctorEntity-PatientEntity-UserEntity](#DoctorEntity-PatientEntity-UserEntity)
    - [SearchResult](#SearchResult)
 - [/networking](#networking)
 - [/repository](#repository)
 - [/services](#services)
 - [/ui](#ui)
    - [/account](#/account)
    - [/cognitiveTest](#/cognitiveTest)
    - [/doctorDetail](#/doctorDetail)
    - [/mainPage](#/mainPage)
    - [/home](#/home)
    - [/neuronioClinic](#/neuronioClinic)
    - [/panel](#/panel)
    - [/patientDetail](#/patientDetail)
    - [/start](#/start)
    - [/visit](#/visit)
    - [/visitsList](#/visitsList)
    - [/widgets](#/widgets)
 - [/utils](#utils)
 - [/main.dart](#main.dart)

## blocs
This project is architected with flutter bloc pattern and all the blocs are defines here.
## constants
Contains address to assets used in different pages, colours in the themes and constant strings
## models
All the Entities that are used in pages or entities that help with sending requests and getting response data from the server are gathered in **models** folder.
   - #### AgoraChannelEntity
      It Is used with **agora_rtc_engine** flutter package in online voice and video calls.
   - ...
   - #### DoctorEntity-PatientEntity-UserEntity
     - ##### UserEntity
        Both **DoctorEntity** and **UserEntity** class extends UserEntity. **UserEntity** contains common attributes of users. It has a User attribute. In **User** class you can see **username**, **avatar(that contains url to access user avatar image from server)**, **phoneNumber** ... .

     - ##### Entity
        Another important class in **UserEntity.dart** file is **Entity** class. It is for both doctors and patients. **mEntity** attribute of this classes contains current logged in user data.
        Attribute **partnerEntity** is Always the opposite type from **mEntity**, for example mEntity can be a doctor and then partnerEntity should be the last recent patient that doctor has to deal with or mEntity can be a patient user and then partnerEntity should be the last recent doctor with a visiting appointment or other events that both users are a member of that event.

    - #### SearchResult
      Mostly in search pages that we have to fetch a list of items from the server, we fill its object with items to pass to widgets.

## networking
Provide a set of interfaces for sending requests with different methods such as **GET**, **POST** and **PATCH**
## repository
Each event such as loading a page or submitting a change in the application, that needs some kind of information from server or needs to send a request, use these files in the repository folder. These files use methods in ApiProvider class describes in the previous item.
## services
This is just for handling push notification in the background.
## ui
Here we have all the ui elements, widgets and the part that navigate between pages.
   - #### /account
     This is **Account Page** for both patient and doctor that shows their billing info or logout bottom or other data that needs every user for their profile.
   - #### /cognitiveTest
     This service is available in **neuronio clinic services** section (third section) and it contains a list of questions that doctors can suggest for their patient and even patient themselves may pay to use.
   - #### /doctorDetail
     This page gives patients all the information of a selected doctor when they are selecting a doctor from the doctor list to set a visit time or ...
   - #### /home
     The first section of the app is **home page** for both doctor and patients that users encounter after logging in to the app.
   - #### /mainPage
     This is the main part of the app after users are logged in that contains a scaffold with a **BottomNavigationBar** attribute that shows 4 sections icons (**home**, **panel**, **service**, **account**) for both users and with tapping on every section it navigates between sections
      and a body which responsible for the content of every section and handles them with **IndexedStack**.
   - #### /neuronioClinic
     This is the third section (**service**) that contains neuronioClinic services such as **free Alzheimer test** , **neuronio doctors**, **useful games** and other services that will be added here.
   - #### /panel
     For every **doctor** and **patient** that have at least one **visit** or **event**, we have one **panel** object that will be created in the database. **Panel** is the main part of communication between patients and doctors. All video/voice calls, visits, chats, health documents, prescribe drugs ... are here. We have three parts in panel section: **DOCTOR_INTERFACE**, **HEALTH_FILE**, **HEALTH_CALENDAR** that **Panel widget** is a template for these three and each one of those parts can have multiple subPages.
     **DOCTOR_INTERFACE**: **IllnessPage**, **ChatPage**, **VideoCallPage**
     **HEALTH_FILE**: **InfoPage**, **InfoPage**, **InfoPage**
     **HEALTH_CALENDAR**: **[DateCalender,TimeCalender]**, **EventPage**, **MedicinePage**
    For example, you can see how the **HEALTH_CALENDAR** panel widget is created in **NavigatorAndView.dart** file in **_panelPages** method.

         Panel(
              onPush: (direction, entity) {
                push(context, direction, detail: entity);
              },
              pages: [
                [
                  DateCalender(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  ),
                  TimeCalender(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  EventPage(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  MedicinePage(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
              ],
            )

   - #### /patientDetail
     Every patient should choose one or more doctors and send them requests and on the other side, doctors will choose their patient by accepting. They can see the patient information on this page to choose to accept or reject them as their will.
   - #### /start
     This is the Starting pages of the app. After opening the app it always shows splashpage for a short period of time the contains just a simple app logo and at that time by checking localStorage of the device in checkToken function of **SplashPage.dart** file, sees if the device has logged in before and if not it goes to **OnBoardingPage.dart** to shows three-page initial introduction of the app. After that, by going to **StartPage** users can write their information to log in.
   - #### /visit
     After getting an appointment time by patient users at a specified time they can use different options (**video call**, **voice call**, **chat room**, ...) to communicate with thier doctor. The page that gives users these options is in the visit folder.
   - #### /visitsList
     So as expected every doctor has some visit appointments and some patient visit requests. They can see all of them on the visits list that is available in three items on home page of the doctor view. By tapping on every one of the items it navigates to the items list and can scroll down and search between them for a better experience.
   - #### /widgets
     In every described page there are some widgets part of the pages that are common such as **Actionbutton**, **OptionButton**, **NeuronioHeader**, **FloatingButton** ... .
     They are used on different pages multiple times so to prevent copying every one of them they are gathered in widgets folder.

## utils
It contains some utilities such as **websocket**, **Extensions**, **customPainter** ...
## main.dart
As a default configuration this file is the start of a flutter project that run the app and beside it uses google firebase crashlytics that report crashes and non-fatal errors that users experience.

## Neuronio Page Navigation
The Main file that handle page navigations is in **/lib/ui/mainPage/NavigatorView**. Build method of this widget is as below:

    @override
    Widget build(BuildContext context) {
        return Navigator(
            key: widget.navigatorKey,
            initialRoute: NavigatorRoutes.root,
            observers: <NavigatorObserver>[HeroController()],
            onGenerateRoute: (settings) => _route(settings, context),
        );
    }
Main structure of the navigaition tree is coded in **_routeBuilder** that is called in **onGeneratedRoute (_route)**.

    Map<String, WidgetBuilder> _routeBuilders(BuildContext context,{detail, widgetArg}) {
        switch (widget.index) {
        case -1:
            return {
                NavigatorRoutes.root: (context) => MainPage(
                    pushOnBase: (direction, entity) {
                    push(context, direction, detail: entity);
                },
              ),
                NavigatorRoutes.doctorDialogue: (context) => _doctorDetailPage(context, detail),
                NavigatorRoutes.patientDialogue: (context) => _patientDetailPage(context, detail),
                /// Other Pages
        };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
            /// Other Pages In Home Section
        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => _myDoctorsList(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.panel: (context) => _panel(context, detail: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
              /// Other Pages In Panel Section

      case 2:
        return {
          NavigatorRoutes.root: (context) => _neuronioClinic(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.doctorSearchView: (context) =>
              _doctorSearchPage(context),
            /// Other Pages In neuronio Clinic Service Section
      case 3:
        return {
          NavigatorRoutes.root: (context) => _account(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.uploadPicDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadSlider(
                listId: detail,
                body: widgetArg,
              )),
              /// Other Pages In Account Section
      default:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
        }
    }
Here **widget.index** determine current **bottomnavigationbar** index. It shows whether we are in **home(index=0)**, **panel (index=1)**, **neuronio clinic service(index=2)** or **account(index=3)** for both doctor and patient.
Every one of those methods (**_home,_notificationPage,_mydoctorList, ...**), returns a widget. For most of the returned widgets, there is an **onPush** attribute that used to change the page to other widgets while staying in the same index.
For example, OnPush method in _home is used to change pages from home root to notificationPage or doctorSearch page.
For some of the returned widgets, there is a **globalOnPush** that used when you want to open up a new page above the pages that hide bottomnavigationbar. For example, it is used to open **cognitive test** in **neuronio clinic services**.
You may see **selectPage** attribute among those returned widget that used to navigate between navigation bars such as navigating between home page and neuronio clinic services that take an **int** as an input to change the index of bottomnavigationbar.
Below is an exmaple of home page widget that you have to pass **selectPage**, **onPush**, **globalOnPush** attributes to **Home** widget.

    Widget _home(context) {
        var entity = BlocProvider.of<EntityBloc>(context).state.entity;
        _notificationBloc.add(GetNewestNotifications());
        if (entity.isDoctor) {
          return MultiBlocProvider(
              providers: [
                BlocProvider<PatientTrackerBloc>.value(
                  value: _trackerBloc,
                ),
                BlocProvider<NotificationBloc>.value(
                  value: _notificationBloc,
                )
              ],
              child: Home(
                selectPage: widget.selectPage,
                onPush: (direction, entity) {
                  push(context, direction, detail: entity);
                },
                globalOnPush: widget.pushOnBase,
              ));
        } else if (entity.isPatient) {
          return MultiBlocProvider(
              providers: [
                BlocProvider<NotificationBloc>.value(
                  value: _notificationBloc,
                )
              ],
              child: Home(
                selectPage: widget.selectPage,
                onPush: (direction, entity) {
                  push(context, direction, detail: entity);
                },
                globalOnPush: widget.pushOnBase,
              ),
             );
        }
    }

So in summary, for adding a new subpage to home or other parts we have to add its named root and widget as key and value in returned map of **_routeBuilders** method.
#### Notification OnClick Navigation
There are different kinds of notification types:
  - Voice OR Video Call
  - Sending Test and Receiving Response
  - Visit
  - Visit Request Reminder
  - Visit Reminder
  - New Patient Registration
  - New Chat Message
  - ...

By clicking on push notifications in android bar or in notification page app should navigate to a specific page. There is a class defined in **/services/NotificationNavigationService.dart** named **NotificationNavigationService**. Main function of this calss is **navigate** that manage page navigation:

    void navigate(BuildContext context, NewestNotif newestNotifs) {
       EntityAndPanelUpdater.processOnEntityLoad((entity) {
           navigation(entity, newestNotifs, context);
        });
    }
This function use **EntityAndPanelUpdater.processOnEntityLoad()** to ensure that the page is loaded after user data is available and then it uses navigation function and by looking at notification type loads a proper page.
