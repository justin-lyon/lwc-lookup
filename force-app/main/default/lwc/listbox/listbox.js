import { LightningElement, api } from 'lwc'

export default class Listbox extends LightningElement {
  @api records
  @api title
  @api context
  @api iconName
  @api activeId

  @api
  selectItem () {
    const items = this.template.querySelectorAll('c-listbox-item')
    items.forEach(item => { item.selectItem() })
  }

  handleSelected (event) {
    const selected = new CustomEvent('selected', {
      bubbles: true,
      detail: event.detail
    })
    this.dispatchEvent(selected)
  }
}
