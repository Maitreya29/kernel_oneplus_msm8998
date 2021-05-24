#define TARGET_UNLIMITED_FPS 2000
#define TARGET_DEFAULT_FPS 1000

switch (_gdfrc_fps_limit) {
	case 90:
		fps_rescue_percent = rescue_percent_90;
		fps_min_rescue_percent = rescue_percent_90;
		fps_short_rescue_ns =
			(rescue_percent_90 == DEF_RESCUE_PERCENT)
			? DEF_RESCUE_NS_TH : vsync_period;
		break;
	case 2000:
		fps_rescue_percent = rescue_percent_2000;
		fps_min_rescue_percent = rescue_percent_2000;
		fps_short_rescue_ns =
			(rescue_percent_2000 == DEF_RESCUE_PERCENT)
			? DEF_RESCUE_NS_TH : vsync_period;
		break;
	case 60:
	default:
		fps_rescue_percent = rescue_percent;
		fps_short_rescue_ns = short_rescue_ns;
		fps_min_rescue_percent = min_rescue_percent;
		break;
	}

	xgf_trace("fps=%d, rescue@(%d, %d, %d)", _gdfrc_fps_limit,
			fps_rescue_percent, fps_min_rescue_percent,
			fps_short_rescue_ns);
