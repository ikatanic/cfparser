open Core
open Async
open Cohttp_async

let get_problems contest_id =
  let contest_uri =
    sprintf "http://codeforces.com/contest/%s" contest_id
    |> Uri.of_string
  in
  Client.get contest_uri
  >>= fun (_resp, body) ->
  Body.to_string body
  >>| fun body ->
  let regex =
    sprintf "\"/contest/%s/problem/([A-Z0-9]*)\"" contest_id
    |> Re.Posix.re
    |> Re.compile
  in
  Re.all regex body
  |> List.map ~f:(fun group -> Re.Group.get group 1)
  |> List.dedup_and_sort ~compare: String.compare 

let get_samples contest_id problem_id =
  let problem_uri =
    sprintf "http://codeforces.com/contest/%s/problem/%s" contest_id problem_id
    |> Uri.of_string
  in
  Client.get problem_uri
  >>= fun (_resp, body) ->
  Body.to_string body
  >>| fun body ->
  let extract tag =
    let div_class, div_title =
      match tag with
      | `Input -> "input", "Input"
      | `Output -> "output", "Output"
    in
    let regex =
      sprintf "<div class=\"%s\"> *<div class=\"title\">%s</div> *<pre>(.*)</pre></div>" div_class div_title
      |> Re.Posix.re
      |> Re.shortest
      |> Re.compile
    in
    Re.all regex body
    |> List.map ~f:(fun group -> Re.Group.get group 1)
    |> List.map ~f:(Re.replace_string (Re.Posix.re "<br */>" |> Re.compile) ~by:"\n")
    |> List.map ~f:(Re.replace_string (Re.Posix.re "^\n*" |> Re.compile) ~by: "")
  in
  let inputs = extract `Input in
  let outputs = extract `Output in
  List.zip_exn inputs outputs

let mkdir path =
  Sys.file_exists path
  >>= function
  | `Yes -> return ()
  | `No | `Unknown -> Unix.mkdir path

let copy_temp_file temp problem_dir problem_id =
  match temp with
  | None -> return ()
  | Some src ->
    let _, ext = Filename.split_extension src in
    let ext = Option.value_map ext ~default:"" ~f:(fun ext -> "." ^ ext) in
    let dst = problem_dir ^/ (problem_id ^ ext) in
    Reader.with_file src ~f:(fun reader ->
        Reader.contents reader
        >>= fun contents ->
        Writer.save dst ~contents
      )

let handle_problem contest_id dir temp problem_id =
  let problem_dir = dir ^/ problem_id in
  mkdir problem_dir
  >>= fun () ->
  copy_temp_file temp problem_dir problem_id
  >>= fun () ->
  get_samples contest_id problem_id
  >>= function
  | [] ->
    printf "Problem %s: no samples found!!\n%!" problem_id;
    return ()
  | samples ->
    Deferred.List.iteri samples ~how:`Parallel ~f:(fun i (input, output) ->
        let input_file = problem_dir ^/ (sprintf "in%d" (i+1)) in
        let output_file = problem_dir ^/ (sprintf "out%d" (i+1)) in
        Deferred.all_unit
          [ (Writer.save input_file ~contents:input)
          ; (Writer.save output_file ~contents:output)]
      )
    >>| fun () ->
    printf "Problem %s: written %d samples.\n%!" problem_id (List.length samples)

let main contest_id dir temp () =
  Deferred.Option.bind (return temp) (fun temp ->
      Sys.file_exists temp
      >>| function
      | `Yes -> Some temp
      | `No | `Unknown ->
        printf "Template %s does not exist.\n%!" temp;
        None
    )
  >>= fun temp ->
  get_problems contest_id
  >>= function
  | [] ->
    printf "No problems found!!\n" |> return
  | problems ->
    printf "Found %d problems.\n%!" (List.length problems);
    let dir = Option.value dir ~default:contest_id in
    mkdir dir
    >>= fun () ->
    Deferred.List.iter problems ~how:`Parallel ~f:(handle_problem contest_id dir temp)

let main () =
  let main_spec =
    let open Command.Spec in
    empty
    +> anon ("contest_id" %: string)
    +> flag "-dir" (optional string) ~doc:"dir directory to store problems. ./contest_id by default."
    +> flag "-temp" (optional string) ~doc:"filename code template to copy for each problem."
  in
  let main_cmd =
    Command.async_spec
      ~summary:"Codeforces contest parser"
      main_spec
      main
  in
  Command.run main_cmd
