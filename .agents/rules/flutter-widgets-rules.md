---
trigger: model_decision
description: When creating, editing or using a Widget in the application.
---

---
name: "flutter-widgets-rules"
description: "Best pratices that must be followed when is creating, editing or using ANY widget of the application."
allowed-tools: Read,Glob,Grep
---

#  Widgets Types

## Page

Pages are the top-level screens of the application. They are always `StatefulWidget`s, but **must** replace `extends State<T>` with `extends ViewState<T, V>` from `fk_booster`.

*   **Location:** `pages/<page_name>/<page_name>_page.dart`.
*   **Responsibility:** Render the UI and delegate all user interactions to the ViewModel.
*   **Rule:** Always a `StatefulWidget` whose `State` extends `ViewState<PageClass, ViewModelClass>`.

## Page Section

Page sections are used to improve the code readability of the pages contents by grouping a few Widgets that make sense to be together, or, to reduce the quantity of lines of a widget in the "page" file by creating a new file to it.

Example: You are developing a page that contains a form with search parameters, a table with the result of the search and a summary with importants data of the search.
Instead adding all the code inside the "page" you will create these sections: <page_name>_form.dart, <page_name>_summary.dart, <page_name>_table.dart.

Important: The sections is expected to be related 1:1 with a page.

*   **Location:** `pages/<page_name>/widgets/sections/<page_name>_<section_name>.dart`.
*   **Responsibility:** Make the pages easier to read.
*   **Rule:** Always create a widget section instead adding big block of codes in the page.

## Core Component

Core components are single Widgets that is developed to be used/reused multiple times and in multiple places of the application.
Example: An custom AppCheckbox Widget, AppButton Widget, AppPageTitle and etc.
These components can be customized by receving multiple parameters in the constructor.

*   **Location:** `core/widgets/components/[Optional]<component_type>/<component_name>.dart`.
*   **Responsibility:** Avoid code repetition in the application by creating an reusable component.
*   **Rule:** Always create a core component when there is a need of creating a widget that will be used in different places of the application.

## Page Component

Page components are like Core Components, BUT, there ONLY should be created when there is a Widget that is TOO specific of an Page, and there is going to be too difficult to use in other pages or features.
These Widgets should not allow too much customizations, if there is a need of it, is probaly should be an core component.
Examples: There is a floating action button in your screen, that uses the AppFloating button. To avoid building the whole button inside your page code you create the widgets/components/<page_name>_<component_name>.dart.

*   **Location:** `pages/<page_name>/widgets/components/[Optional]<component_type>/<component_name>.dart`.
*   **Responsibility:** Improve code redability avoiding code repetition inside pages.
*   **Rule:** Always create a page component when there is a need of creating a widget specific to a page.



