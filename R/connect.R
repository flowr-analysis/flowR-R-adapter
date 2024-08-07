# TODO probably introduce some sort of object-oriented approach here, where send_request and disconnect can be functions in the object returned by connect

#' Connects to a running flowR server at the given host and port
#'
#' @param host The host to connect to. By default, this is "localhost".
#' @param port The port to connect to. By default, this is 1042.
#' @param blocking Whether to use blocking mode for the connection.
#'
#' @seealso [send_request()]
#' @seealso [disconnect()]
#'
#' @export
connect <- function(host = "localhost", port = 1042, blocking = TRUE) {
  connection <- socketConnection(host = host, port = port, server = FALSE, blocking = blocking, open = "r+")

  # the first response is the hello message
  hello <- readLines(connection, n = 1)

  return(list("connection" = connection, "hello" = hello))
}

#' Sends a JSON request to the running flowR server, if connected
#'
#' @param connection The connection to use when sending the request.
#' @param command The command to send, as a named list representing the key-value pairs to set in the JSON request.
#'
#' @seealso [connect()]
#' @seealso [disconnect()]
#'
#' @export
send_request <- function(connection, command) {
  if (is.null(connection)) {
    return()
  }

  request <- jsonlite::toJSON(command, auto_unbox = TRUE)
  writeLines(request, connection)

  response <- readLines(connection, n = 1)
  # we don't simplify anything, so that everything is always a predictable list of lists!
  return(jsonlite::fromJSON(response, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE))
}

#' Closes an active connection to a flowR server, if connected
#'
#' @param connection The connection to close.
#'
#' @seealso [connect()]
#' @seealso [send_request()]
#'
#' @export
disconnect <- function(connection) {
  if (is.null(connection)) {
    return(FALSE)
  }

  close(connection)
  return(TRUE)
}
