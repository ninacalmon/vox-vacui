extends GdUnitTestSuite

const DIARY_SCRIPT := "res://autoloads/diary_database.gd"

func _make():
	return load(DIARY_SCRIPT).new()

func test_pages_contain_four_days() -> void:
	var dd = _make()
	assert_that(dd.pages.has(0)).is_true()
	assert_that(dd.pages.has(1)).is_true()
	assert_that(dd.pages.has(2)).is_true()
	assert_that(dd.pages.has(3)).is_true()
	assert_that(dd.pages.size()).is_equal(4)

func test_get_day_returns_left_and_right_pages() -> void:
	var dd = _make()
	var page: Dictionary = dd.get_day(0)
	assert_that(page.has("left")).is_true()
	assert_that(page.has("right")).is_true()
	assert_that(page["left"].has("head")).is_true()
	assert_that(page["left"].has("main")).is_true()
	assert_that(page["left"].has("sketch")).is_true()

func test_day_zero_has_expected_headline() -> void:
	var dd = _make()
	var page: Dictionary = dd.get_day(0)
	assert_that(String(page["left"]["head"])).contains("Primeiro log")

func test_get_day_unknown_returns_empty_page() -> void:
	var dd = _make()
	var page: Dictionary = dd.get_day(99)
	assert_that(page["left"]["head"]).is_equal("")
	assert_that(page["left"]["main"]).is_equal("")
	assert_that(page["right"]["main"]).is_equal("")
	assert_that(page["left"]["sketch"]).is_null()

func test_get_day_returns_distinct_content_per_day() -> void:
	var dd = _make()
	var day0: Dictionary = dd.get_day(0)
	var day1: Dictionary = dd.get_day(1)
	assert_that(String(day0["left"]["main"])).is_not_empty()
	assert_that(String(day1["left"]["main"])).is_not_empty()
	assert_that(day0["left"]["main"]).is_not_equal(day1["left"]["main"])
