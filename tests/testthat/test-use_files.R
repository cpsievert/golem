test_that("use_external_*_file works", {
	run_quietly_in_a_dummy_golem({
		testthat::with_mocked_bindings(
			utils_download_file = function(
				url,
				there
			) {
				file.create(
					there
				)
			},
			{
				funs_and_ext <- list(
					js = use_external_js_file,
					css = use_external_css_file,
					html = use_external_html_template,
					txt = use_external_file
				)
				mapply(
					function(
						fun,
						ext
					) {
						unlink(
							paste0(
								"this.",
								ext
							)
						)
						expect_error({
							fun(
								url = paste0(
									"this.",
									ext
								),
								golem_wd = ".",
								dir_create = TRUE
							)
						})
						path_to_file <- fun(
							url = paste0(
								"this.",
								ext
							),
							golem_wd = "."
						)
						expect_exists(
							path_to_file
						)
					},
					funs_and_ext,
					names(
						funs_and_ext
					)
				)
			}
		)
	})
})

test_that("use_internal_*_file works", {
	run_quietly_in_a_dummy_golem({
		testthat::with_mocked_bindings(
			fs_file_copy = function(
				url,
				where
			) {
				file.create(
					where
				)
			},
			{
				funs_and_ext <- list(
					js = use_internal_js_file,
					css = use_internal_css_file,
					html = use_internal_html_template,
					txt = use_internal_file
				)
				mapply(
					function(
						fun,
						ext
					) {
						if (ext != "txt") {
							expect_error(
								fun(
									path = "this.nop",
									golem_wd = "."
								)
							)
						}
						path_to_file <- fun(
							path = paste0(
								"this.",
								ext
							),
							golem_wd = "."
						)
						expect_exists(
							path_to_file
						)
						expect_equal(
							file_ext(
								path_to_file
							),
							ext
						)
					},
					funs_and_ext,
					names(
						funs_and_ext
					)
				)
			}
		)
	})
})
