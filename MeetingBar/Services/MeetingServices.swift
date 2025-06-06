//
//  MeetingServices.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 09.04.2022.
//  Copyright © 2022 Andrii Leitsius. All rights reserved.
//

import AppKit
import Defaults
import Foundation

enum MeetingServices: String, Codable, CaseIterable {
    case phone = "Phone"
    case meet = "Google Meet"
    case hangouts = "Google Hangouts"
    case zoom = "Zoom"
    case zoom_native = "Zoom native"
    case teams = "Microsoft Teams"
    case webex = "Cisco Webex"
    case jitsi = "Jitsi"
    case chime = "Amazon Chime"
    case ringcentral = "Ring Central"
    case gotomeeting = "GoToMeeting"
    case gotowebinar = "GoToWebinar"
    case bluejeans = "BlueJeans"
    case eight_x_eight = "8x8"
    case demio = "Demio"
    case join_me = "Join.me"
    case zoomgov = "ZoomGov"
    case whereby = "Whereby"
    case uberconference = "Uber Conference"
    case blizz = "Blizz"
    case teamviewer_meeting = "Teamviewer Meeting"
    case vsee = "VSee"
    case starleaf = "StarLeaf"
    case duo = "Google Duo"
    case voov = "Tencent VooV"
    case facebook_workspace = "Facebook Workspace"
    case lifesize = "Lifesize"
    case skype = "Skype"
    case skype4biz = "Skype For Business"
    case skype4biz_selfhosted = "Skype For Business (SH)"
    case facetime = "Facetime"
    case pop = "Pop"
    case chorus = "Chorus"
    case gong = "Gong"
    case livestorm = "Livestorm"
    case facetimeaudio = "Facetime Audio"
    case youtube = "YouTube"
    case vonageMeetings = "Vonage Meetings"
    case meetStream = "Google Meet Stream"
    case around = "Around"
    case jam = "Jam"
    case discord = "Discord"
    case blackboard_collab = "Blackboard Collaborate"
    case url = "Any Link"
    case coscreen = "CoScreen"
    case vowel = "Vowel"
    case zhumu = "Zhumu"
    case lark = "Lark"
    case feishu = "Feishu"
    case vimeo = "Vimeo"
    case ovice = "oVice"
    case luma = "Luma"
    case preply = "Preply"
    case userzoom = "UserZoom"
    case venue = "Venue"
    case teemyco = "Teemyco"
    case demodesk = "Demodesk"
    case zoho_cliq = "Zoho Cliq"
    case slack = "Slack"
    case gather = "Gather"
    case reclaim = "Reclaim.ai"
    case tuple = "Tuple"
    case pumble = "Pumble"
    case suitConference = "Suit Conference"
    case doxyMe = "Doxy.me"
    case calcom = "Cal Video"
    case zmPage = "zm.page"
    case livekit = "LiveKit Meet"
    case meetecho = "Meetecho"
    case streamyard = "StreamYard"
    case other = "Other"

    var localizedValue: String {
        switch self {
        case .phone:
            return "constants_meeting_service_phone".loco()
        case .zoom_native:
            return "constants_meeting_service_zoom_native".loco()
        case .other:
            return "constants_meeting_service_other".loco()
        case .url:
            return "constants_meeting_service_url".loco()
        default:
            return rawValue
        }
    }
}

public struct MeetingLink: Hashable, Equatable, Sendable {
    let service: MeetingServices?
    var url: URL
}

enum CreateMeetingLinks {
    static let meet = URL(string: "https://meet.google.com/new")!
    static let zoom = URL(string: "https://zoom.us/start?confno=123456789&zc=0")!
    static let teams = URL(string: "https://teams.microsoft.com/l/meeting/new?subject=")!
    static let jam = URL(string: "https://jam.systems/new")!
    static let coscreen = URL(string: "https://cs.new")!
    static let gcalendar = URL(string: "https://calendar.google.com/calendar/u/0/r/eventedit")!
    static let outlook_live = URL(string: "https://outlook.live.com/calendar/0/action/compose")!
    static let outlook_office365 = URL(string: "https://outlook.office365.com/calendar/0/action/compose")!
}

enum CreateMeetingServices: String, Defaults.Serializable, Codable, CaseIterable {
    case meet = "Google Meet"
    case zoom = "Zoom"
    case teams = "Microsoft Teams"
    case jam = "Jam"
    case coscreen = "CoScreen"
    case gcalendar = "Google Calendar"
    case outlook_live = "Outlook Live"
    case outlook_office365 = "Outlook Office365"
    case url = "Custom url"

    var localizedValue: String {
        switch self {
        case .url:
            return "constants_create_meeting_service_url".loco()
        default:
            return rawValue
        }
    }
}

func createMeeting() {
    let browser: Browser = Defaults[.browserForCreateMeeting]

    switch Defaults[.createMeetingService] {
    case .meet:
        openMeetingURL(MeetingServices.meet, CreateMeetingLinks.meet, browser)
    case .zoom:
        openMeetingURL(MeetingServices.zoom, CreateMeetingLinks.zoom, browser)
    case .teams:
        openMeetingURL(MeetingServices.teams, CreateMeetingLinks.teams, browser)
    case .jam:
        openMeetingURL(MeetingServices.jam, CreateMeetingLinks.jam, browser)
    case .coscreen:
        openMeetingURL(MeetingServices.coscreen, CreateMeetingLinks.coscreen, browser)
    case .gcalendar:
        openMeetingURL(nil, CreateMeetingLinks.gcalendar, browser)
    case .outlook_office365:
        openMeetingURL(nil, CreateMeetingLinks.outlook_office365, browser)
    case .outlook_live:
        openMeetingURL(nil, CreateMeetingLinks.outlook_live, browser)
    case .url:
        var url: String = Defaults[.createMeetingServiceUrl]
        let checkedUrl = NSURL(string: url)

        if !url.isEmpty, checkedUrl != nil {
            openMeetingURL(nil, URL(string: url)!, browser)
        } else {
            if !url.isEmpty {
                url += " "
            }

            sendNotification("create_meeting_error_title".loco(), "create_meeting_error_message".loco(url))
        }
    }
}

func openMeetingURL(_ service: MeetingServices?, _ url: URL, _ browser: Browser?) {
    switch service {
    case .meet:
        let browser = browser ?? Defaults[.meetBrowser]
        if browser == meetInOneBrowser {
            let meetInOneUrl = URL(string: "meetinone://url=" + url.absoluteString)!
            meetInOneUrl.openInDefaultBrowser()
        } else {
            url.openIn(browser: browser)
        }
    case .teams:
        let browser = browser ?? Defaults[.teamsBrowser]
        if browser == teamsAppBrowser {
            var teamsAppURL = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            teamsAppURL.scheme = "msteams"
            let result = teamsAppURL.url!.openInDefaultBrowser()
            if !result {
                sendNotification("status_bar_error_app_link_title".loco("Microsoft Teams"), "status_bar_error_app_link_message".loco("Microsoft Teams"))
                url.openInDefaultBrowser()
            }
        } else {
            url.openIn(browser: browser)
        }
    case .zoom, .zoomgov:
        let browser = browser ?? Defaults[.zoomBrowser]
        if browser == zoomAppBrowser {
            if url.absoluteString.contains("/my/") {
                url.openIn(browser: systemDefaultBrowser)
            }
            let urlString = url.absoluteString.replacingOccurrences(of: "?", with: "&").replacingOccurrences(of: "/j/", with: "/join?confno=")
            var zoomAppUrl = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
            zoomAppUrl.scheme = "zoommtg"
            let result = zoomAppUrl.url!.openInDefaultBrowser()
            if !result {
                sendNotification("status_bar_error_app_link_title".loco("Zoom"), "status_bar_error_app_link_message".loco("Zoom"))
                url.openInDefaultBrowser()
            }
        } else {
            url.openIn(browser: browser)
        }
    case .zoom_native:
        let result = url.openInDefaultBrowser()
        if !result {
            sendNotification("status_bar_error_app_link_title".loco("Zoom"), "status_bar_error_app_link_message".loco("Zoom"))

            let urlString = url.absoluteString.replacingFirstOccurrence(of: "&", with: "?").replacingOccurrences(of: "/join?confno=", with: "/j/")
            var zoomBrowserUrl = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
            zoomBrowserUrl.scheme = "https"
            zoomBrowserUrl.url!.openInDefaultBrowser()
        }
    case .jitsi:
        let browser = browser ?? Defaults[.jitsiBrowser]
        if browser == jitsiAppBrowser {
            var jitsiAppUrl = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            jitsiAppUrl.scheme = "jitsi-meet"
            let result = jitsiAppUrl.url!.openInDefaultBrowser()
            if !result {
                sendNotification("status_bar_error_app_link_title".loco("Jitsi"), "status_bar_error_app_link_message".loco("Jitis"))
                url.openInDefaultBrowser()
            }
        } else {
            url.openIn(browser: browser)
        }
    case .slack:
        let browser = browser ?? Defaults[.slackBrowser]
        if browser == slackAppBrowser {
            let teamID = url.pathComponents[2]
            let huddleID = url.pathComponents[3]

            let slackUrl = URL(string: "slack://join-huddle?team=\(teamID)&id=\(huddleID)")!
            let result = slackUrl.openInDefaultBrowser()
            if !result {
                sendNotification("status_bar_error_app_link_title".loco("Slack"), "status_bar_error_app_link_message".loco("Slack"))
                url.openInDefaultBrowser()
            }
        } else {
            url.openIn(browser: browser)
        }
    case .facetime:
        NSWorkspace.shared.open(URL(string: "facetime://" + url.absoluteString)!)
    case .facetimeaudio:
        NSWorkspace.shared.open(URL(string: "facetime-audio://" + url.absoluteString)!)
    case .phone:
        NSWorkspace.shared.open(URL(string: "tel://" + url.absoluteString)!)
    default:
        url.openIn(browser: browser ?? Defaults[.defaultBrowser])
    }
}

private let meetingLinkRegexes: [MeetingServices: NSRegularExpression] = [
    .meet: try! NSRegularExpression(pattern: #"https?://meet.google.com/(_meet/)?[a-z-]+"#),
    .zoom: try! NSRegularExpression(pattern: #"https:\/\/(?:[a-zA-Z0-9-.]+)?zoom(-x)?\.(?:us|com|com\.cn|de)\/(?:my|[a-z]{1,2}|webinar)\/[-a-zA-Z0-9()@:%_\+.~#?&=\/]*"#),
    .zoom_native: try! NSRegularExpression(pattern: #"zoommtg://([a-z0-9-.]+)?zoom(-x)?\.(?:us|com|com\.cn|de)/join[-a-zA-Z0-9()@:%_\+.~#?&=\/]*"#),
    .teams: try! NSRegularExpression(pattern: #"https?://(gov.)?teams\.microsoft\.(com|us)/l/meetup-join/[a-zA-Z0-9_%\/=\-\+\.?]+"#),
    .webex: try! NSRegularExpression(pattern: #"https?://(?:[A-Za-z0-9-]+\.)?webex\.com(?:(?:/[-A-Za-z0-9]+/j\.php\?MTID=[A-Za-z0-9]+(?:&\S*)?)|(?:/(?:meet|join)/[A-Za-z0-9\-._@]+(?:\?\S*)?))"#),
    .chime: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?chime\.aws/[0-9]*"#),
    .jitsi: try! NSRegularExpression(pattern: #"https?://meet\.jit\.si/[^\s]*"#),
    .ringcentral: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?ringcentral\.com/[^\s]*"#),
    .gotomeeting: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?gotomeeting\.com/[^\s]*"#),
    .gotowebinar: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?gotowebinar\.com/[^\s]*"#),
    .bluejeans: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?bluejeans\.com/[^\s]*"#),
    .eight_x_eight: try! NSRegularExpression(pattern: #"https?://8x8\.vc/[^\s]*"#),
    .demio: try! NSRegularExpression(pattern: #"https?://event\.demio\.com/[^\s]*"#),
    .join_me: try! NSRegularExpression(pattern: #"https?://join\.me/[^\s]*"#),
    .whereby: try! NSRegularExpression(pattern: #"https?://whereby\.com/[^\s]*"#),
    .uberconference: try! NSRegularExpression(pattern: #"https?://uberconference\.com/[^\s]*"#),
    .blizz: try! NSRegularExpression(pattern: #"https?://go\.blizz\.com/[^\s]*"#),
    .teamviewer_meeting: try! NSRegularExpression(pattern: #"https?://go\.teamviewer\.com/[^\s]*"#),
    .vsee: try! NSRegularExpression(pattern: #"https?://vsee\.com/[^\s]*"#),
    .starleaf: try! NSRegularExpression(pattern: #"https?://meet\.starleaf\.com/[^\s]*"#),
    .duo: try! NSRegularExpression(pattern: #"https?://duo\.app\.goo\.gl/[^\s]*"#),
    .voov: try! NSRegularExpression(pattern: #"https?://voovmeeting\.com/[^\s]*"#),
    .facebook_workspace: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?workplace\.com/groupcall/[^\s]+"#),
    .skype: try! NSRegularExpression(pattern: #"https?://join\.skype\.com/[^\s]*"#),
    .lifesize: try! NSRegularExpression(pattern: #"https?://call\.lifesizecloud\.com/[^\s]*"#),
    .youtube: try! NSRegularExpression(pattern: #"https?://((www|m)\.)?(youtube\.com|youtu\.be)/[^\s]*"#),
    .vonageMeetings: try! NSRegularExpression(pattern: #"https?://meetings\.vonage\.com/[0-9]{9}"#),
    .meetStream: try! NSRegularExpression(pattern: #"https?://stream\.meet\.google\.com/stream/[a-z0-9-]+"#),
    .around: try! NSRegularExpression(pattern: #"https?://(meet\.)?around\.co/[^\s]*"#),
    .jam: try! NSRegularExpression(pattern: #"https?://jam\.systems/[^\s]*"#),
    .discord: try! NSRegularExpression(pattern: #"(http|https|discord)://(www\.)?(canary\.)?discord(app)?\.([a-zA-Z]{2,})(.+)?"#),
    .blackboard_collab: try! NSRegularExpression(pattern: #"https?://us\.bbcollab\.com/[^\s]*"#),
    .coscreen: try! NSRegularExpression(pattern: #"https?://join\.coscreen\.co/[^\s]*"#),
    .vowel: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?vowel\.com/#/g/[^\s]*"#),
    .zhumu: try! NSRegularExpression(pattern: #"https://welink\.zhumu\.com/j/[0-9]+?pwd=[a-zA-Z0-9]+"#),
    .lark: try! NSRegularExpression(pattern: #" https://vc\.larksuite\.com/j/[0-9]+"#),
    .feishu: try! NSRegularExpression(pattern: #"https://vc\.feishu\.cn/j/[0-9]+"#),
    .vimeo: try! NSRegularExpression(pattern: #"https://vimeo\.com/(showcase|event)/[0-9]+|https://venues\.vimeo\.com/[^\s]+"#),
    .ovice: try! NSRegularExpression(pattern: #"https://([a-z0-9-.]+)?ovice\.in/[^\s]*"#),
    .facetime: try! NSRegularExpression(pattern: #"https://facetime\.apple\.com/join[^\s]*"#),
    .chorus: try! NSRegularExpression(pattern: #"https?://go\.chorus\.ai/[^\s]+"#),
    .pop: try! NSRegularExpression(pattern: #"https?://pop\.com/j/[0-9-]+"#),
    .gong: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?join\.gong\.io/[^\s]+"#),
    .livestorm: try! NSRegularExpression(pattern: #"https?://app\.livestorm\.com/p/[^\s]+"#),
    .luma: try! NSRegularExpression(pattern: #"https://lu\.ma/join/[^\s]*"#),
    .preply: try! NSRegularExpression(pattern: #"https://preply\.com/[^\s]*"#),
    .userzoom: try! NSRegularExpression(pattern: #"https://go\.userzoom\.com/participate/[a-z0-9-]+"#),
    .venue: try! NSRegularExpression(pattern: #"https://app\.venue\.live/app/[^\s]*"#),
    .teemyco: try! NSRegularExpression(pattern: #"https://app\.teemyco\.com/room/[^\s]*"#),
    .demodesk: try! NSRegularExpression(pattern: #"https://demodesk\.com/[^\s]*"#),
    .zoho_cliq: try! NSRegularExpression(pattern: #"https://cliq\.zoho\.eu/meetings/[^\s]*"#),
    .zoomgov: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?zoomgov\.com/j/[a-zA-Z0-9?&=]+"#),
    .skype4biz: try! NSRegularExpression(pattern: #"https?://meet\.lync\.com/[^\s]*"#),
    .skype4biz_selfhosted: try! NSRegularExpression(pattern: #"https?:\/\/(meet|join)\.[^\s]*\/[a-z0-9.]+/meet\/[A-Za-z0-9./]+"#),
    .hangouts: try! NSRegularExpression(pattern: #"https?://hangouts\.google\.com/[^\s]*"#),
    .slack: try! NSRegularExpression(pattern: #"https?://app\.slack\.com/huddle/[A-Za-z0-9./]+"#),
    .reclaim: try! NSRegularExpression(pattern: #"https?://reclaim\.ai/z/[A-Za-z0-9./]+"#),
    .tuple: try! NSRegularExpression(pattern: #"https://tuple\.app/c/[^\s]*"#),
    .gather: try! NSRegularExpression(pattern: #"https?://app.gather.town/app/[A-Za-z0-9]+/[A-Za-z0-9_%\-]+\?(spawnToken|meeting)=[^\s]*"#),
    .pumble: try! NSRegularExpression(pattern: #"https?://meet\.pumble\.com/[a-z-]+"#),
    .suitConference: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?conference\.istesuit\.com/[^\s]*+"#),
    .doxyMe: try! NSRegularExpression(pattern: #"https://([a-z0-9.]+)?doxy\.me/[^\s]*"#),
    .calcom: try! NSRegularExpression(pattern: #"https?://app.cal\.com/video/[A-Za-z0-9./]+"#),
    .zmPage: try! NSRegularExpression(pattern: #"https?://([a-zA-Z0-9.]+)\.zm\.page"#),
    .livekit: try! NSRegularExpression(pattern: #"https?://meet[a-zA-Z0-9.]*\.livekit\.io/rooms/[a-zA-Z0-9-#]+"#),
    .meetecho: try! NSRegularExpression(pattern: #"https?://meetings\.conf\.meetecho\.com/.+"#),
    .streamyard: try! NSRegularExpression(pattern: #"https://(?:www\.)?streamyard\.com/(?:guest/)?([a-z0-9]{8,13})(?:/|\?[^ \n]*)?"#)
]

func regex(for service: MeetingServices) -> NSRegularExpression? {
    meetingLinkRegexes[service]
}

func detectMeetingLink(_ rawText: String) -> MeetingLink? {
    let text = cleanupOutlookSafeLinks(rawText: rawText)

    for pattern in Defaults[.customRegexes] {
        if let regex = try? NSRegularExpression(pattern: pattern) {
            if let link = getMatch(text: text, regex: regex) {
                if let url = URL(string: link) {
                    return MeetingLink(service: MeetingServices.other, url: url)
                }
            }
        }
    }

    if text.contains("://") {
        for (svc, regex) in meetingLinkRegexes {
            if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                let url = String(text[Range(match.range, in: text)!])
                return MeetingLink(service: svc, url: URL(string: url)!)
            }
        }
    }
    return nil
}

private nonisolated(unsafe) var iconCache: [MeetingServices?: NSImage] = [:]

func getIconForMeetingService(_ meetingService: MeetingServices?) -> NSImage {
    if let cached = iconCache[meetingService] {
        return cached
    }

    var image = NSImage(named: "no_online_session")!
    image.size = NSSize(width: 16, height: 16)

    switch meetingService {
    // tested and verified
    case .some(.teams):
        image = NSImage(named: "ms_teams_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.meet), .some(.meetStream):
        image = NSImage(named: "google_meet_icon")!
        image.size = NSSize(width: 16, height: 13.2)

    // tested and verified -> deprecated, can be removed because hangouts was replaced by google meet
    case .some(.hangouts):
        image = NSImage(named: "google_hangouts_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.zoom), .some(.zoomgov), .some(.zoom_native):
        image = NSImage(named: "zoom_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.reclaim):
        // reclaim only uses its own links when zoom is involved, so they are always zoom links
        // see https://devforum.zoom.us/t/major-zoom-gcal-sync-problems-recent-behavior-change/80912
        image = NSImage(named: "zoom_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.webex):
        image = NSImage(named: "webex_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.jitsi):
        image = NSImage(named: "jitsi_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.chime):
        image = NSImage(named: "amazon_chime_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.ringcentral):
        image = NSImage(named: "ringcentral_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.gotomeeting):
        image = NSImage(named: "gotomeeting_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.gotowebinar):
        image = NSImage(named: "gotowebinar_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.bluejeans):
        image = NSImage(named: "bluejeans_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.eight_x_eight):
        image = NSImage(named: "8x8_icon")!
        image.size = NSSize(width: 16, height: 8)

    // tested and verified
    case .some(.demio):
        image = NSImage(named: "demio_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.join_me):
        image = NSImage(named: "joinme_icon")!
        image.size = NSSize(width: 16, height: 10)

    // tested and verified
    case .some(.whereby):
        image = NSImage(named: "whereby_icon")!
        image.size = NSSize(width: 16, height: 18)

    // tested and verified
    case .some(.uberconference):
        image = NSImage(named: "uberconference_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.blizz), .some(.teamviewer_meeting):
        image = NSImage(named: "teamviewer_meeting_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.vsee):
        image = NSImage(named: "vsee_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.starleaf):
        image = NSImage(named: "starleaf_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.duo):
        image = NSImage(named: "google_duo_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.voov):
        image = NSImage(named: "voov_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.skype):
        image = NSImage(named: "skype_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.skype4biz), .some(.skype4biz_selfhosted):
        image = NSImage(named: "skype_business_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.lifesize):
        image = NSImage(named: "lifesize_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.facebook_workspace):
        image = NSImage(named: "facebook_workplace_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.youtube):
        image = NSImage(named: "youtube_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.coscreen):
        image = NSImage(named: "coscreen_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.vowel):
        image = NSImage(named: "vowel_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.zhumu):
        image = NSImage(named: "zhumu_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.lark):
        image = NSImage(named: "lark_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.feishu):
        image = NSImage(named: "feishu_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.vimeo):
        image = NSImage(named: "vimeo_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.ovice):
        image = NSImage(named: "ovice_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.facetime), .some(.facetimeaudio):
        image = NSImage(named: "facetime_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.pop):
        image = NSImage(named: "pop_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.chorus):
        image = NSImage(named: "chorus_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.livestorm):
        image = NSImage(named: "livestorm_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.gong):
        image = NSImage(named: "gong_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.preply):
        image = NSImage(named: "preply_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.userzoom):
        image = NSImage(named: "userzoom_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.venue):
        image = NSImage(named: "venue_icon")!
        image.size = NSSize(width: 16, height: 4)

    // tested and verified
    case .some(.teemyco):
        image = NSImage(named: "teemyco_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.demodesk):
        image = NSImage(named: "demodesk_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.zoho_cliq):
        image = NSImage(named: "zoho_cliq_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.slack):
        image = NSImage(named: "slack_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.tuple):
        image = NSImage(named: "tuple_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.pumble):
        image = NSImage(named: "pumble_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.suitConference):
        image = NSImage(named: "suit_conference_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.doxyMe):
        image = NSImage(named: "doxy_me_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.zmPage):
        image = NSImage(named: "zm_page_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.livekit):
        image = NSImage(named: "livekit_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.meetecho):
        image = NSImage(named: "meetecho_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.streamyard):
        image = NSImage(named: "streamyard_icon")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .none:
        image = NSImage(named: "no_online_session")!
        image.size = NSSize(width: 16, height: 16)

    // tested and verified
    case .some(.vonageMeetings):
        image = NSImage(named: "vonage_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.gather):
        image = NSImage(named: "gather_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.calcom):
        image = NSImage(named: "calcom_icon")!
        image.size = NSSize(width: 16, height: 16)

    case .some(.url):
        image = NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!
        image.size = NSSize(width: 16, height: 16)

    case .some(.phone):
        image = NSImage(named: NSImage.touchBarCommunicationAudioTemplateName)!
        image.size = NSSize(width: 16, height: 16)

    default:
        break
    }

    iconCache[meetingService] = image
    return image
}
