import { LightningElement, api } from 'lwc'

export default class ListboxItem extends LightningElement {
  @api record
  @api title
  @api subtitle
  @api iconName
  @api activeId

  @api
  selectItem (currentId) {
    if (this.isActive || currentId === this.record.Id) this.clickRecord()
  }

  get label () { return this.record[this.title] }
  get subLabel () { return this.record[this.subtitle] }
  get isActive () { return this.activeId === this.record.Id }

  get itemClasses () {
    const classes = [
      'slds-media',
      'slds-listbox__option',
      'slds-listbox__option_entity',
      'slds-listbox__option_has-meta' ]

    if (this.isActive) {
      classes.push('slds-has-focus')
    }

    return classes.join(' ')
  }

  clickRecord () {
    const selected = new CustomEvent('selected', {
      detail: this.record.Id
    })
    this.dispatchEvent(selected)
  }
}
