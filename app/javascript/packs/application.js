import $ from "jquery";
import "select2";
import "@ttskch/select2-bootstrap4-theme/dist/select2-bootstrap4.css"; // Bootstrap4テーマ
import "select2/dist/css/select2.css"; // select2の基本CSS

$(document).on("turbo:frame-load turbo:load turbo:render", function () {
  console.log("aaa");
  $(".select2").select2({
    theme: "bootstrap4",
    width: "100%",
    placeholder: "選択してください",
    allowClear: true,
  });
});
