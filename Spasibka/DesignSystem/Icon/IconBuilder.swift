//
//  Icons.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.06.2022.
//

import StackNinja
import UIKit

protocol IconElements: InitProtocol, DesignElementable where DesignElement == UIImage {}

extension IconElements {
   var copyToClipboard: UIImage { make("tabler_copy_clipboard") }
   var attach: UIImage { make("akar-icons_attach") }
   var bell: UIImage { make("bell") }
   var calendar: UIImage { make("calendar") }
   var cross: UIImage { make("tabler_mark") }
   var inProgress: UIImage { make("in_progress") }
   var lock: UIImage { make("lock") }
   var mail: UIImage { make("mail") }

   var share: UIImage { make("share") }
   var exchange: UIImage { make("exchange") }

   var user: UIImage { make("user") }

   var alarm: UIImage { make("alarm") }
   var messageCloud: UIImage { make("message_cloud") }
   var like: UIImage { make("like") }
   var dislike: UIImage { make("dislike") }

   // brand
   var logoCurrency: UIImage { make("dt_currency_logo") }
   var logoCurrencyRed: UIImage { make("dt_currency_logo_red") }
   var logoCurrencyBig: UIImage { make("dt_currency_logo_big") }

   // illustrate
   var introlIllustrate: UIImage { make("dt_main") }
   var buyBenefitsSuccessIllustration: UIImage { make("buy_benefits_success_illustration") }

   // other
   var upload2Fill: UIImage { make("upload-2-fill") }
   var coinLine: UIImage { make("coin-line") }
   var coinBackground: DesignElement { make("coin-background") }

   var historyLine: UIImage { make("history-line") }
   var checkLine: DesignElement { make("check-line") }
   var checkCircle: UIImage { make("check_circle_24px") }
   var calendarLine: UIImage { make("calendar-line") }

   var avatarPlaceholder: UIImage { make("avatar") }
   var newAvatar: UIImage { make("avatar") }
   var challengeAvatar: UIImage { make("challengeAvatar") }
   var anonAvatar: UIImage { make("anon_avatar") }

   var sideMenu: UIImage { make("menu_24px") }

   var arrowDropDownLine: UIImage { make("arrow-drop-down-line") }
   var arrowDropUpLine: UIImage { make("arrow-drop-up-line") }
   var arrowDropRightLine: UIImage { make("arrow-drop-right-line") }

   var clapHands: UIImage { make("bloom_woman_and_man_clapped_their_hands_1") }

   var recieveCoinIcon: UIImage { make("recieve_coin_icon") }
   var sendCoinIcon: UIImage { make("send_coin_icon") }

   var burn: UIImage { make("burn") }

   var bottomPanel: UIImage { make("bottom_panel") }

   var tabBarMainButton: UIImage { make("dt_tabbar_main_button") }
   var tabBarButton1: UIImage { make("house-line") }
   var tabBarButton2: UIImage { make("credit-card") }
   var tabBarButton3: UIImage { make("medal1") }
   var tabBarButton4: UIImage { make("ben") }

   // transact
   var transactSuccess: UIImage { make("dt_transact_success") }
   var userNotFound: UIImage { make("dt_not_found") }

   // profile
   var editCircle: UIImage { make("edit_circle") }
   var camera: UIImage { make("tabler_camera") }

   // errors
   var errorIllustrate: UIImage { make("dt_error_illustrate") }

   // tabler
   var tablerAerialLift: UIImage { make("tabler_aerial-lift") }
   var tablerAlertCircle: UIImage { make("tabler_alert-circle") }
   var tablerArrowBackUp: UIImage { make("tabler_arrow-back-up") }
   var tablerArrowLeft: UIImage { make("tabler_arrow-left") }
   var tablerAward: UIImage { make("tabler_award") }
   var tablerBell: UIImage { make("tabler_bell") }
   var tablerBook: UIImage { make("tabler_book") }
   var tablerBrandRedhat: UIImage { make("tabler_brand-redhat") }
   var tablerBrandSnapchat: UIImage { make("tabler_brand-snapchat") }
   var tablerBrandTelegram: UIImage { make("tabler_brand-telegram") }
   var tablerBriefcase: UIImage { make("tabler_briefcase") }
   var tablerBuildingArch: UIImage { make("tabler_building-arch") }
   var tablerCalendar: UIImage { make("tabler_calendar") }
   var tablerCamera: UIImage { make("tabler_camera") }
   var tablerCameraOff: UIImage { make("tabler_camera-off") }
   var tablerCameraRotate: UIImage { make("tabler_camera-rotate") }
   var tablerCategory2: UIImage { make("tabler_category-2") }
   var tablerChess: UIImage { make("tabler_chess") }
   var tablerChevronDown: UIImage { make("tabler_chevron-down") }
   var tablerChevronRight: UIImage { make("tabler_chevron-right") }
   var tablerChevronUp: UIImage { make("tabler_chevron-up") }
   var tablerCircleCheck: UIImage { make("tabler_circle-check") }
   var tablerCirclePlus: UIImage { make("tabler_circle-plus") }
   var tablerClipboardText: UIImage { make("tabler_clipboard-text") }
   var tablerClock: UIImage { make("tabler_clock") }
   var tablerCreditCard: UIImage { make("tabler_credit-card") }
   var tablerDevicesPc: UIImage { make("tabler_devices-pc") }
   var tablerDiamond: UIImage { make("tabler_diamond") }
   var tablerDots: UIImage { make("tabler_dots") }
   var tablerEditCircle: UIImage { make("tabler_edit-circle") }
   var tablerFilter: UIImage { make("tabler_filter") }
   var tablerGift: UIImage { make("tabler_gift") }
   var tablerGiftBrand: UIImage { make("tabler_gift_brand") }
   var tablerHeartPlus: UIImage { make("tabler_heart-plus") }
   var tablerHeartbeat: UIImage { make("tabler_heartbeat") }
   var tablerHistory: UIImage { make("tabler_history") }
   var tablerInfoCircle: UIImage { make("tabler_info-circle") }
   var tablerKeyboard: UIImage { make("tabler_keyboard") }
   var tablerKeyboardShow: UIImage { make("tabler_keyboard-show") }
   var tablerLayoutDashboard: UIImage { make("tabler_layout-dashboard") }
   var tablerLogin: UIImage { make("tabler_login") }
   var tablerLogout: UIImage { make("tabler_logout") }
   var tablerMailOpened: UIImage { make("tabler_mail-opened") }
   var tablerMapIn: UIImage { make("tabler_map-pin") }
   var tablerMark: UIImage { make("tabler_mark") }
   var tablerMessageCircle: UIImage { make("tabler_message-circle-2") }
   var tablerMoodSmile: UIImage { make("tabler_mood-smile") }
   var tablerPhone: UIImage { make("tabler_phone") }
   var tablerPlus: UIImage { make("tabler_plus") }
   var tablerRefresh: UIImage { make("tabler_refresh") }
   var tablerRobot: UIImage { make("tabler_robot") }
   var tablerRocket: UIImage { make("tabler_rocket") }
   var tablerSearch: UIImage { make("tabler_search") }
   var tablerSettings: UIImage { make("tabler_settings") }
   var tablerShare: UIImage { make("tabler_share") }
   var tablerShoppingCart: UIImage { make("tabler_shopping-cart") }
   var tablerSmartHome: UIImage { make("tabler_smart-home") }
   var tablerTrain: UIImage { make("tabler_train") }
   var tablerTrash: UIImage { make("tabler_trash") }
   var tablerUser: UIImage { make("tabler_user") }
   var tablerUserCheck: UIImage { make("tabler_user-check") }
   var tablerUsers: UIImage { make("tabler_users") }
   var tablerWalk: UIImage { make("tabler_walk") }
   var tablerWifiOff: UIImage { make("tabler_wifi-off") }
   var tablerWorld: UIImage { make("tabler_world") }

   //
   var uilShieldSlash: UIImage { make("uil_shield-slash") }

   // illusttrates
   var challengeWinnerIllustrateFull: UIImage { make("challenge_winner_illustrate_full") }
   var challengeWinnerIllustrateMedium: UIImage { make("challenge_winner_illustrate_medium") }
   var challengeWinnerIllustrate: UIImage { make("challenge_winner_illustrate") }
   var smartPeopleIllustrate: UIImage { make("smart_people_illustrate") }
   var businessDealIllustrate: UIImage { make("business_deal_illustrate") }
   var onboardSuccessIllustrate: UIImage { make("onboard_success_illustrate") }

   // challenges
   var strangeLogo: UIImage { make("strange_icon") }

   // brand logos
   var logoVKontakte: UIImage { make("vk_logo") }
   var logoVKontakteButton: UIImage { make("vk_logo_button") }

   // new challenges
   var lockOutline: UIImage { make("lock-outline") }
   
   // flags
   var usaFlag: UIImage { make("usa_flag") }
   var russiaFlag: UIImage { make("russia_flag") }
   var shareDefault: UIImage { .init(systemName: "square.and.arrow.up") ?? .init() }
   
   //new design
   var heart: UIImage { make("heart") }
   var redHeart: UIImage { make("red_heart") }
   var comment: UIImage { make("comment") }
   var chatCircle: UIImage { make("chat_circle") }
   var medal: UIImage { make("medal") }
   var basket: UIImage { make("basket") }
   var desktop: UIImage { make("desktop") }
   var navBarBackButton: UIImage { make("CaretLeft") }
   var navBarMenuButton: UIImage { make("FunnelSimple") }
   var balanceCellBackground: UIImage { make("balance_cell_background") }
   var balanceBack: UIImage { make("balanceBack") }
   var threeDotsCircle: UIImage { make("DotsThreeCircle") }
   var rocket: UIImage { make("Rocket") }
   var arrowLineUp: UIImage { make("ArrowLineUp") }
   var usersThree: UIImage { make("UsersThree") }
   var clock: UIImage { make("Clock") }
   var gift: UIImage { make("Gift") }
   var clipboardText: UIImage { make("ClipboardText") }
   var warningCircle: UIImage { make("WarningCircle") }
   var lockThin: UIImage { make("Lock") }
   var spinnerGap: UIImage { make("SpinnerGap") }
   var checkCircleThin: UIImage { make("CheckCircle") }
   var plus: UIImage { .init(systemName: "plus")! }

   var historyIcon: UIImage { make("history-icon") }
   var participantsIcon: UIImage { make("participants-icon") }
   var rewardsIcon: UIImage { make("rewards-icon") }
   
   var chainSectionHeaderStep1: UIImage { checkCircleThin }
   var chainSectionHeaderStep2: UIImage { spinnerGap }
   var chainSectionHeaderStep3: UIImage { lockThin }
   var notepad: UIImage { make("notepad") }
   var cancelButton: UIImage { make("cancelButton") }
   var ticketHeartIcon: UIImage { make("ticketHeartIcon") }
   var newAlarm: UIImage { make("Notification-icon") }
   var thanksGroupBack: UIImage { make("thanks-group") }
   var cake: UIImage { make("cake") }
   var pencilSimple: UIImage { make("PencilSimple") }
   var xCross: UIImage { make("XCross") }
   var trash: UIImage { make("Trash") }
   var garage: UIImage { make("Garage") }
   var filterIcon: UIImage { make("filterIcon") }
   var searchIcon: UIImage { make("MagnifyingGlass") }
   
   var challengeCover1: UIImage { make("challengeCover1") }
   var challengeCover2: UIImage { make("challengeCover2") }
   var challengeCover3: UIImage { make("challengeCover3") }
   var challengeCover4: UIImage { make("challengeCover4") }
   var challengeCover5: UIImage { make("challengeCover5") }
}

extension IconElements {
   var smallSpasibkaLogo: UIImage {
      make("dt_logo")
   }

   var loginSpasibkaLogo: UIImage {
      make("login_logo")
   }

   var smallLogo: UIImage {
      BrandSettings.shared.brandImageForKey(.smallLogo) ?? smallSpasibkaLogo
   }

   var loginLogo: UIImage {
      BrandSettings.shared.brandImageForKey(.loginLogo) ?? loginSpasibkaLogo
   }

   var menuLogo: UIImage {
      BrandSettings.shared.brandImageForKey(.menuLogo) ?? make("menu_logo")
   }
}

private extension IconElements {
   func make(_ name: String) -> UIImage {
      UIImage(named: name) ?? {
         print("\n##### Image named: \(name) not found! #####\n")
         return UIImage()
      }()
   }
}

struct IconBuilder: IconElements {
   typealias DesignElement = UIImage
}
