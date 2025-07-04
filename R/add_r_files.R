add_r_files <- function(
	name,
	ext = c(
		"fct",
		"utils"
	),
	module = "",
	golem_wd = get_golem_wd(),
	open = TRUE,
	dir_create = TRUE,
	with_test = FALSE,
	pkg
) {
	signal_arg_is_deprecated(
		pkg,
		fun = as.character(
			sys.call()[[1]]
		),
		"pkg"
	)
	name <- file_path_sans_ext(
		name
	)

	check_name_length_is_one(
		name
	)

	old <- setwd(
		fs_path_abs(
			golem_wd
		)
	)
	on.exit(
		setwd(
			old
		)
	)

	dir_created <- create_if_needed(
		"R",
		type = "directory"
	)

	if (!dir_created) {
		cat_dir_necessary()
		return(
			invisible(
				FALSE
			)
		)
	}

	if (
		!is.null(
			module
		)
	) {
		# Remove the extension if any
		module <- file_path_sans_ext(
			module
		)
		# Remove the "mod_" if any
		module <- mod_remove(
			module
		)
		if (
			!is_existing_module(
				module,
				golem_wd = golem_wd
			)
		) {
			# Check for esoteric 'mod_mod_' module names and if that fails throw error
			if (
				!is_existing_module(
					paste0(
						"mod_",
						module
					),
					golem_wd = golem_wd
				)
			) {
				stop(
					sprintf(
						"The module '%s' does not exist.\nYou can call `golem::add_module('%s')` to create it.",
						module,
						module
					),
					call. = FALSE
				)
			}
			module <- paste0(
				"mod_",
				module
			)
		}
		module <- paste0(
			"mod_",
			module,
			"_"
		)
	}

	where <- fs_path(
		"R",
		paste0(
			module,
			ext,
			"_",
			name,
			".R"
		)
	)

	if (
		!fs_file_exists(
			where
		)
	) {
		fs_file_create(
			where
		)

		if (
			fs_file_exists(
				where
			) &
				is.null(
					module
				)
		) {
			# Must be a function or utility file being created
			append_roxygen_comment(
				name = name,
				path = where,
				ext = ext
			)
		}

		cat_created(
			where
		)
	} else {
		file_already_there_dance(
			where = where,
			open_file = open
		)
	}

	if (with_test) {
		usethis_use_test(
			basename(
				file_path_sans_ext(
					where
				)
			),
			open = open
		)
	}

	open_or_go_to(
		where,
		open
	)
}

#' Add fct_ and utils_ files
#'
#' These functions add files in the R/ folder
#' that starts either with `fct_` (short for function)
#' or with `utils_`.
#'
#' @param name The name of the file
#' @param module If not NULL, the file will be module specific
#'     in the naming (you don't need to add the leading `mod_`).
#' @inheritParams  add_module
#'
#' @rdname file_creation
#' @export
#'
#' @return The path to the file, invisibly.
add_fct <- function(
	name,
	module = NULL,
	golem_wd = get_golem_wd(),
	open = TRUE,
	dir_create = TRUE,
	with_test = FALSE,
	pkg
) {
	signal_arg_is_deprecated(
		pkg,
		fun = as.character(
			sys.call()[[1]]
		),
		"pkg"
	)
	add_r_files(
		name,
		module,
		ext = "fct",
		golem_wd = golem_wd,
		open = open,
		dir_create = dir_create,
		with_test = with_test
	)
}

#' @rdname file_creation
#' @export
add_utils <- function(
	name,
	module = NULL,
	golem_wd = get_golem_wd(),
	open = TRUE,
	dir_create = TRUE,
	with_test = FALSE,
	pkg
) {
	signal_arg_is_deprecated(
		pkg,
		fun = as.character(
			sys.call()[[1]]
		),
		"pkg"
	)
	add_r_files(
		name,
		module,
		ext = "utils",
		golem_wd = golem_wd,
		open = open,
		dir_create = dir_create,
		with_test = with_test
	)
}

#' @rdname file_creation
#' @export
add_r6 <- function(
	name,
	module = NULL,
	golem_wd = get_golem_wd(),
	open = TRUE,
	dir_create = TRUE,
	with_test = FALSE,
	pkg
) {
	signal_arg_is_deprecated(
		pkg,
		fun = as.character(
			sys.call()[[1]]
		),
		"pkg"
	)
	add_r_files(
		name,
		module,
		ext = "class",
		golem_wd = golem_wd,
		open = open,
		dir_create = dir_create,
		with_test = with_test
	)
}
#' Append roxygen comments to `fct_` and `utils_` files
#'
#' This function add boilerplate roxygen comments
#' for fct_ and utils_ files.
#'
#' @param name The name of the file
#' @param path The path to the R script where the module will be written.
#' @param ext A string denoting the type of file to be created.
#'
#' @rdname file_creation
#' @noRd
append_roxygen_comment <- function(
	name,
	path,
	ext,
	export = FALSE
) {
	write_there <- write_there_builder(
		path
	)

	file_type <- " "

	if (ext == "utils") {
		file_type <- "utility"
	} else if (ext == "fct") {
		file_type <- "function"
	} else {
		ext <- paste(
			ext,
			"generator"
		)
		file_type <- "R6"
	}

	write_there(
		sprintf(
			"#' %s ",
			name
		)
	)
	write_there(
		"#'"
	)
	write_there(
		sprintf(
			"#' @description A %s function",
			ext
		)
	)
	write_there(
		"#'"
	)
	if (!(file_type == "R6")) {
		write_there(
			sprintf(
				"#' @return The return value, if any, from executing the %s.",
				file_type
			)
		)
		write_there(
			"#'"
		)
	}
	if (export) {
		write_there(
			"#' @export"
		)
	} else {
		write_there(
			"#' @noRd"
		)
	}
	if (file_type == "function") {
		write_there(
			paste(
				name,
				"<- function() {"
			)
		)
		write_there(
			"}"
		)
	}
	if (file_type == "R6") {
		write_there(
			paste0(
				name,
				" <- R6::R6Class("
			)
		)
		write_there(
			paste0(
				"  classname = '",
				name,
				"',"
			)
		)
		write_there(
			"  public = list()"
		)
		write_there(
			")"
		)
	}
}
