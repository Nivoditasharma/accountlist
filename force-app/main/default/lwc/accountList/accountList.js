import { LightningElement, wire } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';
import deleteUser from '@salesforce/apex/AccountController.deleteUser';
import fetchUsers from '@salesforce/apex/UserController.fetchUsers';

export default class AccountList extends LightningElement {
    accounts;
    selectedAccountId;
    showEditModal = false;
    showOwnerModal = false;
    users;

    @wire(getAccountList)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleDelete(event) {
        const accountId = event.target.dataset.id;
        deleteUser({ accountId })
            .then(() => {
                // Handle successful deletion
                // Refresh account list or remove the deleted record from the current list
            })
            .catch((error) => {
                // Handle error
                console.error(error);
            });
    }

    handleEdit(event) {
        this.selectedAccountId = event.target.dataset.id;
        this.showEditModal = true;
    }

    handleEditModalClose() {
        // Logic to handle closing of the edit modal
        this.showEditModal = false;
        // Refresh account list or update the edited record in the current list
    }

    handleChangeOwner(event) {
        this.selectedAccountId = event.target.dataset.id;
        fetchUsers()
            .then((data) => {
                this.users = data;
                this.showOwnerModal = true;
            })
            .catch((error) => {
                // Handle error
                console.error(error);
            });
    }

    handleOwnerModalClose() {
        // Logic to handle closing of the owner modal
        this.showOwnerModal = false;
        // Refresh account list or update the ownership of the record in the current list
    }
}
