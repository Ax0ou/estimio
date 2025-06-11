// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import ProductsSearchController from "./products_search_controller"
eagerLoadControllersFrom("controllers", application)
import EditableRowController from "./editable_row_controller"
application.register("editable-row", EditableRowController)
import AutoExpandController from "./auto_expand_controller"
application.register("auto-expand", AutoExpandController)
