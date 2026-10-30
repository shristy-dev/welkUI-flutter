import 'package:flutter/widgets.dart';

import 'screens/bottom_nav_screen.dart';
import 'screens/app_bar_screen.dart';
import 'screens/button_screen.dart';
import 'screens/card_screen.dart';
import 'screens/display_widgets_screen.dart';
import 'screens/form_controls_screen.dart';
import 'screens/image_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/overlay_widgets_screen.dart';
import 'screens/picker_widgets_screen.dart';
import 'screens/qr_code_screen.dart';
import 'screens/switch_screen.dart';

/// The single source for home navigation and documentation preview routes.
const widgetCatalog = <({String name, String route, Widget screen})>[
  (name: 'WelkAppBar', route: '/app-bar', screen: AppBarScreen()),
  (name: 'WelkButton', route: '/button', screen: ButtonScreen()),
  (name: 'WelkSwitch', route: '/switch', screen: SwitchScreen()),
  (name: 'WelkCard', route: '/card', screen: CardScreen()),
  (name: 'WelkMenu', route: '/menu', screen: MenuScreen()),
  (name: 'WelkImage', route: '/image', screen: ImageScreen()),
  (name: 'WelkAccordion', route: '/accordion', screen: AccordionScreen()),
  (name: 'WelkAttachment', route: '/attachment', screen: AttachmentScreen()),
  (name: 'WelkAvatar', route: '/avatar', screen: AvatarScreen()),
  (name: 'WelkBadge', route: '/badge', screen: BadgeScreen()),
  (name: 'WelkBottomNavBar', route: '/bottom-nav', screen: BottomNavScreen()),
  (name: 'WelkBreadCrumbs', route: '/breadcrumbs', screen: BreadCrumbsScreen()),
  (name: 'WelkCheckBox', route: '/checkbox', screen: CheckBoxScreen()),
  (name: 'WelkDateInput', route: '/date-input', screen: DateInputScreen()),
  (name: 'WelkDatePicker', route: '/date-picker', screen: DatePickerScreen()),
  (name: 'WelkDialog', route: '/dialog', screen: DialogScreen()),
  (name: 'WelkDivider', route: '/divider', screen: DividerScreen()),
  (name: 'WelkDrawer', route: '/drawer', screen: DrawerScreen()),
  (name: 'WelkDropDown', route: '/dropdown', screen: DropDownScreen()),
  (name: 'WelkIconButton', route: '/icon-button', screen: IconButtonScreen()),
  (name: 'WelkInput', route: '/input', screen: InputScreen()),
  (name: 'WelkOTPInput', route: '/otp-input', screen: OTPInputScreen()),
  (name: 'WelkQRCode', route: '/qr-code', screen: QRCodeScreen()),
  (name: 'WelkRadio', route: '/radio', screen: RadioScreen()),
  (name: 'WelkRadioGroup', route: '/radio-group', screen: RadioGroupScreen()),
  (
    name: 'WelkRangeSlider',
    route: '/range-slider',
    screen: RangeSliderScreen(),
  ),
  (name: 'WelkSnackBar', route: '/snackbar', screen: SnackBarScreen()),
  (name: 'WelkSticker', route: '/sticker', screen: StickerScreen()),
  (
    name: 'WelkStickerCard',
    route: '/sticker-card',
    screen: StickerCardScreen(),
  ),
  (name: 'WelkTabs', route: '/tabs', screen: TabsScreen()),
  (name: 'WelkTimePicker', route: '/time-picker', screen: TimePickerScreen()),
  (name: 'WelkTooltip', route: '/tooltip', screen: TooltipScreen()),
];
