import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import docxJs from "@salesforce/resourceUrl/DocxJs";
import onBoarding_Image from "@salesforce/resourceUrl/onBoarding_Image";
import getCurrentAccount from '@salesforce/apex/onboardingWordDocController.getCurrentAccount';
import uploadFile from '@salesforce/apex/onboardingWordDocController.uploadFile';
import getExternalData from '@salesforce/apex/onboardingWordDocController.getExternalData';
import checkActiveAccount from '@salesforce/apex/onboardingWordDocController.checkActiveAccount';
import { CurrentPageReference } from 'lightning/navigation';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';


export default class OnboardingWordDoc extends LightningElement {
    @track headerImage;
    @track dbLogo;
    @track footerImage;
    @track downloadURL = '';
    @track document;
    _no_border;
    @api accountId;
    @track spinner = ODS_Statussign;
    @track filename;
    @track externalData = [];
    @wire(CurrentPageReference)
    currentPageReference;
    @track currentAccount;
    @track headingBorder = {
        bottom: {
            color: "365F91",
            space: 5,
            value: "single",
            size: 5,
        }
    }
    @track headingSectionBorder = {
        bottom: {
            color: "0000FF",
            space: 5,
            value: "single",
            size: 5,
        }
    }
    imageEncodeLogo() {
        fetch(onBoarding_Image + '/dbLogo.png')
            .then(response => response.blob())
            .then(blob => {
                // Convert the binary data to Base64
                const reader = new FileReader();
                reader.readAsDataURL(blob);
                reader.onloadend = () => {
                    // Set the Base64-encoded image as the source for the <img> tag
                    // console.log(reader.result);
                    this.dbLogo = reader.result;
                    this.buildDocument();

                };
            })
            .catch(error => {
                console.error(error);
            });
    }
    imageEncodeHeaderTop() {
        fetch(onBoarding_Image + '/headerImage.jpg')
            .then(response => response.blob())
            .then(blob => {
                // Convert the binary data to Base64
                const reader = new FileReader();
                reader.readAsDataURL(blob);
                reader.onloadend = () => {
                    // Set the Base64-encoded image as the source for the <img> tag
                    this.headerImage = reader.result;
                    this.imageEncodeHeaderBottom();
                };
            })
            .catch(error => {
                console.error(error);
            });
    }
    imageEncodeHeaderBottom() {
        fetch(onBoarding_Image + '/footerImage.jpg')
            .then(response => response.blob())
            .then(blob => {
                // Convert the binary data to Base64
                const reader = new FileReader();
                reader.readAsDataURL(blob);
                reader.onloadend = () => {
                    // Set the Base64-encoded image as the source for the <img> tag
                    // console.log(reader.result);
                    this.footerImage = reader.result;
                    this.imageEncodeLogo();
                };
            })
            .catch(error => {
                console.error(error);
            });
    }
    connectedCallback() {

        Promise.all(
            [
                loadScript(this, docxJs)
            ]).then(() => {
                if (!this.accountId) {
                    if (this.currentPageReference && this.currentPageReference.state) {
                        this.accountId = this.currentPageReference.state.recordId;
                    } else {
                        let urlParams = new URLSearchParams(window.location.search);
                        this.accountId = urlParams.get('id');
                    }
                }
                checkActiveAccount({ accountId: this.accountId })
                    .then(result => {
                        if (result == true) {
                            alert('This account is not setup for On-boarding Document automation. Please contact ODS Portal Support.');
                        } else {
                            getExternalData({ accountId: this.accountId })
                                .then(result => {
                                    this.showSpinner();
                                    if (result) {
                                        this.externalData = result;
                                        if (this.externalData) {
                                            getCurrentAccount({ accountId: this.accountId })
                                                .then(data => {
                                                    if (data) {
                                                        this.currentAccount = data;
                                                        if (this.currentAccount) {
                                                            this.imageEncodeHeaderTop();
                                                        }
                                                    }
                                                })
                                                .catch(error => {
                                                    this.error = error;
                                                });
                                        }
                                    } else {
                                        alert('ODS External Data is not availble on this account.');
                                        window.top.close();
                                        this.hideSpinner();
                                    }
                                })
                                .catch(error => {
                                    this.error = error;
                                    this.hideSpinner();
                                });
                        }
                    })
                    .catch(error => {
                        this.error = error;
                        this.hideSpinner();
                    });


                this.no_border = {
                    top: { style: docx.BorderStyle.THICK_THIN_MEDIUM_GAP, size: 5, color: "FFFFFF" },
                    bottom: { style: docx.BorderStyle.THICK_THIN_MEDIUM_GAP, size: 5, color: "FFFFFF" },
                    left: { style: docx.BorderStyle.THICK_THIN_MEDIUM_GAP, size: 5, color: "FFFFFF" },
                    right: { style: docx.BorderStyle.THICK_THIN_MEDIUM_GAP, size: 5, color: "FFFFFF" }
                };
            }).catch(error => {
                console.log(' Error Occured-- ', +error);
            });
    }
    showSpinner() {
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "block";
        }
    }
    hideSpinner() {
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "none";
        }
    }
    pageBreak() {
        return new docx.Paragraph({
            text: "",
            pageBreakBefore: true,
        });
    }
    buildDocument() {

        this.showSpinner();
        try {
            this.document = new docx.Document({
                features: {
                    //trackRevisions: true,
                    updateFields: true,
                }
            });
            //page 1
            this.generatePage1();
            this.document.addSection({

                headers: {
                    default: this.headerContent(),
                },
                footers: {
                    default: this.footerContent(),
                },
                children: [
                    ...this.generatePage2(),
                    this.pageBreak(),
                    ...this.generateTOC(),
                    this.pageBreak(),
                    ...this.generateContent(),
                    this.pageBreak(),
                    ...this.generateSection1(),
                    this.pageBreak(),
                    ...this.generateSection2(),
                    this.pageBreak(),
                    ...this.generateSection3(),
                    this.pageBreak(),
                    ...this.generateSection4(),
                    this.pageBreak(),
                    ...this.generateSection5(),
                    this.pageBreak(),
                    ...this.generateSection6(),
                    this.pageBreak(),
                    ...this.generateSection7(),
                    this.pageBreak(),
                    ...this.generateSection8(),
                    this.pageBreak(),
                    ...this.generateSection9(),
                ]
            });
            docx.Packer.toBase64String(this.document).then(textBlob => {
                this.downloadURL = 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,' + textBlob;
                if (this.downloadURL) {
                    var eve = setTimeout(() => {
                        let name = this.currentAccount.Name + '_OnBoarding_Document';
                        this.filename = name + '.docx';
                        uploadFile({ base64: textBlob, filename: name, recordId: this.accountId })
                            .then(data => {
                                this.hideSpinner();
                                this.template.querySelector('a').click();
                                clearTimeout(eve);
                                alert('On-boarding Document generated successfully.');
                                window.top.close();

                            })
                            .catch(error => {
                                this.error = error;
                                this.hideSpinner();

                            });
                    }, 5000);
                }
            });

        } catch (e) {
            alert(e.name + ' : ' + e.message);
            console.trace("Message");
            this.hideSpinner();

        }
    }

    generatePage1() {

        const topHeaderImage = docx.Media.addImage(this.document, this.headerImage, 780, 405);
        const bottomHeaderImage = docx.Media.addImage(this.document, this.footerImage, 780, 480);
        const logoDB = docx.Media.addImage(this.document, this.dbLogo, 210, 50);

        this.document.addSection({
            properties: { titlePage: true },
            margins: {
                top: 100,
                right: 100,
                bottom: 100,
                left: 100,
            },
            children: [
                new docx.Paragraph(topHeaderImage),
                new docx.Paragraph({
                    children: [logoDB],
                    alignment: docx.AlignmentType.CENTER,
                }),
                new docx.Paragraph({
                    children: [
                        this.runParagraph('On-Demand Services – Salesforce.com', true, 44, 'Segoe UI', '000000', false)
                    ],
                    alignment: docx.AlignmentType.CENTER,
                }),
                this.breakRow(),
                this.breakRow(),
                new docx.Paragraph({
                    children: [
                        this.runParagraph('Onboarding Document For', true, 44, 'Segoe UI', '000000', false)
                    ],
                    alignment: docx.AlignmentType.CENTER,
                }),
                this.breakRow(),
                new docx.Paragraph({
                    children: [
                        this.runParagraph(this.currentAccount.Name, true, 44, 'Segoe UI', '000000', false)
                    ],
                    alignment: docx.AlignmentType.CENTER,
                }),
                new docx.Paragraph(bottomHeaderImage),

            ],
        });
    }

    generatePage2() {
        let r = [
            this.breakRow(),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Document History', false, 24, 'Times New Roman', '000000', false)
                ],
            }),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                indent: { left: 300 },
                rows: [
                    new docx.TableRow({
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlackText('S. No')],
                                borders: this._no_border,
                                width: {
                                    size: 500,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlackText('Version No')],
                                borders: this._no_border,
                                width: {
                                    size: 600,
                                    type: docx.WidthType.DXA,
                                },
                            }), new docx.TableCell({
                                children: [this.runHeaderRowBlackText('Date of Release')],
                                borders: this._no_border,
                                width: {
                                    size: 1300,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlackText('Prepared By')],
                                borders: this._no_border,
                                width: {
                                    size: 800,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlackText('List of changes')],
                                borders: this._no_border,
                                width: {
                                    size: 2900,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlackText('Reviewed/Approved By')],
                                borders: this._no_border,
                                width: {
                                    size: 2000,
                                    type: docx.WidthType.DXA,
                                },
                            })
                        ],
                        shading: {
                            fill: 'E6F3FF',
                        },
                    }),
                    new docx.TableRow({
                        children: [
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),

                        ]
                    }),
                    new docx.TableRow({
                        children: [
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                            new docx.TableCell({ children: [], borders: this._no_border }),
                        ]
                    })
                ]
            }),
        ];
        return r
    }
    generateTOC() {
        let r = [
            new docx.Paragraph({
                border: this.headingBorder,
                children: [
                    new docx.TextRun({ text: 'TABLE OF CONTENTS', bold: true, size: 28, font: { name: "Cambria" }, color: '365F91' })
                ],
                heading: docx.HeadingLevel.TITLE,
                alignment: docx.AlignmentType.LEFT,
            }),
            new docx.Paragraph(''),
            /*     new docx.TableOfContents("TABLE OF CONTENTS", {
                     hyperlink: true,
                     headingStyleRange: "1-5",
                     stylesWithLevels: [{ style: "myHeading1Style", level: 1 },
                     { style: "myHeadingStyle", level: 2 },
                     { style: "myHeadingStyle", level: 3 },
                     { style: "myHeadingStyle", level: 4 },
                     { style: "myHeadingStyle", level: 5 },
                     ],
                 }),*/

        ];
        return r;
    }
    generateContent() {


        let tableCells = [];
        tableCells.push(this.generateHeaderRow());
        tableCells.push(this.generateRow('1. Introduction', 'CSM'));
        tableCells.push(this.generateRow('2. Understand Customer Business', 'CSM'));
        tableCells.push(this.generateRow('3. Understand IT & Salesforce Landscape', 'CSM'));
        tableCells.push(this.generateRow('4. Setup', 'Delivery Team'));
        tableCells.push(this.generateRow('5. Knowledge Transfer', 'CSM & Delivery Team'));
        tableCells.push(this.generateRow('   5.1 Salesforce Org', 'Delivery Team'));
        tableCells.push(this.generateRow('   5.2 Business Process', 'CSM'));
        tableCells.push(this.generateRow('   5.3 Architecture Diagram', 'CSM & Delivery Team'));
        tableCells.push(this.generateRow('   5.4 Development Process & Methodology', 'CSM'));
        tableCells.push(this.generateRow('   5.5 QA Process', 'CSM'));
        tableCells.push(this.generateRow('   5.6 Release Process', 'CSM'));
        tableCells.push(this.generateRow('   5.7 Salesforce Object Model', 'Delivery Team'));
        tableCells.push(this.generateRow('   5.8 Integration', 'Delivery Team'));
        tableCells.push(this.generateRow('   5.9 Data Import/Export Processes', 'Delivery Team'));
        tableCells.push(this.generateRow('   5.10 App-exchange Apps', 'Delivery Team'));
        tableCells.push(this.generateRow('   5.11 Custom Apps', 'Delivery Team'));
        tableCells.push(this.generateRow('6. Engagement Process', 'CSM'));
        tableCells.push(this.generateRow('7. Observations & Recommendations', 'Delivery Team'));
        tableCells.push(this.generateRow('8. Reference Documents', 'CSM & Delivery Team'));
        tableCells.push(this.generateRow('9. Glossary', 'CSM & Delivery Team'));

        let r = [
            this.generateHeading1('RESPONSIBILITY MATRIX'),
            this.breakRow(),
            new docx.Paragraph({
                children: [
                    this.runParagraph('This section provides details on who is responsible for the different sections in the document. The CSM will have the accountability for the timely completion and the quality of the document. The CSM should ensure that the document has enough details and provides value to the customer before sharing it with the customer.', false, 24, 'Times New Roman', '002060', false)
                ],
                alignment: docx.AlignmentType.JUSTIFIED,
            }),
            this.breakRow(),
            new docx.Paragraph({
                children: [
                    this.runParagraph('This section should be removed from the document before it is being submitted to the customer.', false, 24, 'Times New Roman', 'FF0000', false)
                ],
                alignment: docx.AlignmentType.JUSTIFIED,
            }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 8000,
                    type: docx.WidthType.DXA,
                },
                rows: tableCells
            }),
        ];
        return r;
    }
    generateHeaderRow() {
        var tableHeaderRow = new docx.TableRow({
            cantSplit: true,
            children: [
                new docx.TableCell({

                    children: [new docx.Paragraph({
                        indent: { left: 200 },
                        children: [new docx.TextRun({ text: 'Section', bold: true, size: 24, font: 'Times New Roman', color: '002060' })],
                    }
                    )],
                    borders: this._no_border,
                    width: {
                        size: 450,
                        type: docx.WidthType.DXA,
                    },
                }),
                new docx.TableCell({
                    children: [new docx.Paragraph({ indent: { left: 200 }, children: [new docx.TextRun({ text: 'Responsible', bold: true, size: 24, font: 'Times New Roman', color: '002060' })] })],
                    borders: this._no_border,
                    width: {
                        size: 400,
                        type: docx.WidthType.DXA,
                    },
                })
            ]
        });
        return tableHeaderRow;
    }
    generateRow(textContent1, textContent2) {
        var tableRow = new docx.TableRow({
            cantSplit: true,
            children: [
                new docx.TableCell({
                    children: [new docx.Paragraph({
                        indent: { left: 400 },
                        children: [new docx.TextRun({ text: textContent1, bold: false, size: 24, font: 'Times New Roman', color: '002060' })],
                    }
                    )],
                    borders: this._no_border
                }),
                new docx.TableCell({

                    children: [new docx.Paragraph({ indent: { left: 200 }, children: [new docx.TextRun({ text: textContent2, bold: false, size: 24, font: 'Times New Roman', color: '002060' })] })],
                    borders: this._no_border
                })
            ]
        });

        return tableRow;
    }
    generateSection1() {
        let r = [
            this.generateHeading1('1 INTRODUCTION'),
            this.generateHeading2('1.1 Purpose'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The onboarding document will act as a foundational document that will capture all relevant information regarding the customer, their business, IT landscape, and how Salesforce is being leveraged by the customer. This acts as an important tool to do knowledge transfer (KT). At DemandBlue, we understand that our customer has more important tasks to do than spend a lot of time with us in doing knowledge transfer. That is the reason we invest a lot of time by reviewing your Salesforce org and trying to understand how you have been utilizing/leveraging the Salesforce org and documenting it in this onboarding document, thereby optimally utilizing your time.', false, 24, 'Segoe UI', '002060', false),
                ], alignment: docx.AlignmentType.JUSTIFIED,

            }),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Once the draft version of this document is ready, we reach out to you to set up a meeting to confirm the following,', false, 24, 'Segoe UI', '002060', false)

                ],
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            new docx.Paragraph({
                children: [
                    this.runParagraph('What we know', false, 24, 'Segoe UI', '002060', false)
                ],
                bullet: {
                    level: 0,
                },
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            new docx.Paragraph({
                children: [
                    this.runParagraph('What we think we know', false, 24, 'Segoe UI', '002060', false)

                ],
                bullet: {
                    level: 0,
                },
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            new docx.Paragraph({
                children: [
                    this.runParagraph('What we need to know', false, 24, 'Segoe UI', '002060', false)
                ],
                bullet: {
                    level: 0,
                },
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Once we confirm and get all the relevant information, the onboarding documentation will be completed. The KT activity can go in parallel with any immediate needs that you might want to get it done.', false, 24, 'Segoe UI', '002060', false)
                ],
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            this.generateHeading2('1.2 Stakeholders'),
        ];
        return r;
    }
    generateSection2() {

        let r = [
            this.generateHeading1('2 UNDERSTAND CUSTOMERS BUSINESS'),
            this.generateHeading2('2.1 Business Overview'),
            this.runValueText(this.currentAccount.Business_Overview__c),
            this.generateHeading2('2.2 Products / Services Offered'),
            this.runValueText(this.currentAccount.Products_Services_Offered__c),
            this.generateHeading2('2.3 Customers'),
            this.runValueText(this.currentAccount.Customers__c),
            this.generateHeading2('2.4 Key Competitors'),
            this.runValueText(this.currentAccount.Key_Competitors__c),
            this.generateHeading2('2.5 Collaborators / Partners'),
            this.runValueText(this.currentAccount.Collaborators_Partners__c),
            this.generateHeading2('2.6 Compliance'),
            this.runValueText(this.currentAccount.Compliance_Requirements__c),
            this.generateHeading2('2.7 Salesforce Roadmap'),
            this.runValueText(this.currentAccount.Salesforce_Roadmap__c),
            this.generateHeading2('2.8 Enterprise Systems'),
            this.runValueText(this.currentAccount.ERP__c),
            this.generateHeading2('2.9 Product Backlog | Jira Stories'),
            this.runValueText(this.currentAccount.Product_Backlog__c),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 8000,
                    type: docx.WidthType.DXA,
                },
                alignment: docx.AlignmentType.CENTER,
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Issue key', 24)],
                                borders: this._no_border,
                                width: {
                                    size: 1000,
                                    type: docx.WidthType.DXA,
                                },
                                verticalAlign: docx.VerticalAlign.CENTER,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Summary', 24)],
                                borders: this._no_border,
                                width: {
                                    size: 7000,
                                    type: docx.WidthType.DXA,
                                },
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                        ],

                    }),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                ]
            }),
            this.generateHeading2('2.10 Current Pain Points'),
            this.runValueText(this.currentAccount.Current_Painpoints__c),

        ];
        return r;
    }
    generateSection3() {
        let userLicenses = null;
        if (typeof this.externalData['UserLicenses'] != 'undefined') {
            userLicenses = JSON.parse(this.externalData['UserLicenses']);
        }
        let permissionSet = null;
        if (typeof this.externalData['PermissionSetLicenses'] != 'undefined') {
            permissionSet = JSON.parse(this.externalData['PermissionSetLicenses']);
        }
        let featureLicenses = null;
        if (typeof this.externalData['FeatureLicenses'] != 'undefined') {
            featureLicenses = JSON.parse(this.externalData['FeatureLicenses']);
        }
        let userLicensesRow = [];
        userLicensesRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('USER LICENSES'), '', ''));
        if (userLicenses != null) {
            userLicenses.records.forEach(i => {
                userLicensesRow.push(this.Row3ColWithValue(i.Name, i.UsedLicenses, i.TotalLicenses - i.UsedLicenses));
            });
        }
        userLicensesRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('PERMISSION SET LICENSES'), '', ''));
        if (permissionSet != null) {
            permissionSet.records.forEach(i => {
                userLicensesRow.push(this.Row3ColWithValue(i.MasterLabel, i.UsedLicenses, i.TotalLicenses - i.UsedLicenses));
            });
        }
        let featureTypeSumArray = [];

        if (featureLicenses != null && featureLicenses.records && featureLicenses.records.length > 0) {
            userLicensesRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('FEATURE LICENSES'), '', ''));
            featureLicenses.records.forEach(record => {
                const featureType = record.FeatureType;
                const activeUserCount = record.ActiveUserCount;
                const totalLicenseCount = record.TotalLicenseCount;
                const existingFeatureType = featureTypeSumArray.find(item => item.featureType === featureType);
                if (existingFeatureType) {
                    existingFeatureType.sumActiveUserCount += activeUserCount;
                } else {
                    featureTypeSumArray.push({
                        featureType: featureType,
                        sumActiveUserCount: activeUserCount,
                        totalLicenseCount: totalLicenseCount
                    });
                }
            });
            featureTypeSumArray.forEach(i => {
                userLicensesRow.push(this.Row3ColWithValue(i.featureType, i.sumActiveUserCount, i.totalLicenseCount - i.sumActiveUserCount));
            });
        }
        let OrganizationApi = JSON.parse(this.externalData['Organization']);
        let OrganizationRow = [];
        if (OrganizationApi != null) {
            OrganizationApi.records.forEach(i => {
                let line = (i.IsSandbox) ? 'Sandbox' : 'Production';
                OrganizationRow.push(new docx.Paragraph({ children: [this.runParagraph('Instance: ' + line + ' (' + i.InstanceName + ')', true, 22, 'Calibri', '002060', false)] }));
            });
        }
        let limitsAPI = JSON.parse(this.externalData['Limits']);
        let limitsRow = [];
        if (limitsAPI != null) {
            limitsRow.push(this.Row3ColWithValue('API Requests, Last 24 Hours', limitsAPI.DailyApiRequests.Max, limitsAPI.DailyApiRequests.Max - limitsAPI.DailyApiRequests.Remaining));
            limitsRow.push(this.Row3ColWithValue('Data Storage', limitsAPI.DataStorageMB.Max + ' MB', limitsAPI.DataStorageMB.Max - limitsAPI.DataStorageMB.Remaining + ' MB'));
            limitsRow.push(this.Row3ColWithValue('File Storage', limitsAPI.FileStorageMB.Max + ' MB', limitsAPI.FileStorageMB.Max - limitsAPI.FileStorageMB.Remaining + ' MB'));
        }
        let r = [
            this.generateHeading1('3 SETUP'),
            this.generateHeading2('3.1 Environment'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('<DemandBlue ODS team will be primarily working on the development environment which could be the Full/Partial Sandbox or the Developer sandbox. This section will detail not only the development environment but also the other environments like QA, UAT and Production>', false, 20, 'Verdana', '7ED7A6', true)
                ],
                alignment: docx.AlignmentType.JUSTIFIED,

            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Environment', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Sandbox Name', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            })
                        ]
                    }),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                ]
            }),
            this.generateHeading2('3.2 Data Migration'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('<Developer sandbox doesn’t have any data but the development team would require minimum data to work in the developer sandbox. The section to detail the data needs and process to have the data moved to sandbox>', false, 20, 'Verdana', '7ED7A6', true)
                ],
                alignment: docx.AlignmentType.JUSTIFIED,
            }),
            this.generateHeading2('3.3 Salesforce Licenses '),
            ...OrganizationRow,
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Salesforce License Type')],
                                borders: this._no_border,

                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Used Licenses')],
                                borders: this._no_border
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Available License')],
                                borders: this._no_border
                            })
                        ]
                    }),
                    ...userLicensesRow,
                ]
            }),
            this.breakRow(),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The API requests, data usage and file usage mentioned below:', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Type')],
                                borders: this._no_border,

                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Limit')],
                                borders: this._no_border
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Used')],
                                borders: this._no_border
                            })
                        ]
                    }),
                    ...limitsRow,
                ]
            }),
            this.generateHeading3('3.3.1 Subscription Details'),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 6500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Product')],
                                borders: this._no_border
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Licenses')],
                                borders: this._no_border
                            })
                        ]
                    }),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                    this.emptyRow2Col(),
                ]
            }),
            this.generateHeading3('3.3.2 User Last Login Report'),
            this.generateHeading2('3.4 User Accounts'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('<This section will detail the development resources who have been given access to the different salesforce environments and also other tools that might be used along with salesforce>', false, 20, 'Verdana', '7ED7A6', true)
                ],
            }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Resource Name', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('User Name', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Environment', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            })
                        ]
                    }),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                ]
            }),
            this.generateHeading2('3.5 Roles/Permissions'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('This section details the roles and permissions of the DemandBlue resources in the different environments and the tools>', false, 20, 'Verdana', '7ED7A6', true)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('User Name', 18)],
                                borders: this._no_border,
                                width: {
                                    size: 3700,
                                    type: docx.WidthType.DXA,
                                },
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Email', 18)],
                                borders: this._no_border,
                                width: {
                                    size: 3700,
                                    type: docx.WidthType.DXA,
                                },
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Role/Profile', 18)],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Permission Sets', 18)],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            })
                        ]
                    }),
                    this.emptyRow4ColGrey(),
                    this.emptyRow4ColGrey(),
                    this.emptyRow4ColGrey(),
                    this.emptyRow4ColGrey(),
                    this.emptyRow4ColGrey(),
                ]
            }),
        ];
        return r;
    }
    generateSection4() {

        let customObjectAPI = null;
        if (typeof this.externalData['Custom Objects'] != 'undefined') {
            customObjectAPI = JSON.parse(this.externalData['Custom Objects']);
        }

        let customObjectrow = [];
        if (customObjectAPI != null) {
            customObjectAPI.records.forEach(i => {
                customObjectrow.push(this.Row3ColWithValue(i.DeveloperName, '', i.Description));
            });
        }
        let apexClassApi = null;
        if (typeof this.externalData['Apex Class'] != 'undefined') {
            apexClassApi = JSON.parse(this.externalData['Apex Class']);
        }
        let apexclassRow = [];
        let apexCount = 0;
        if (apexClassApi != null) {
            apexClassApi.records.forEach(i => {
                var coverage = (parseInt(i.NumLinesCovered) / (parseInt(i.NumLinesCovered) + parseInt(i.NumLinesUncovered))) * 100;
                if (isNaN(coverage)) {
                    coverage = 0;
                }
                coverage = coverage.toFixed(0);
                if(i.ApexClassOrTrigger != null){
                apexclassRow.push(this.Row2ColWithValue(i.ApexClassOrTrigger.Name, coverage + '%'));
                }
            });
            apexCount = apexClassApi.totalSize;
        }
        let omniAPI = null;
        if (typeof this.externalData['OmniChannel'] != 'undefined') {
            omniAPI = JSON.parse(this.externalData['OmniChannel']);
        }
        let omniRow = [];
        if (omniAPI != null) {
            omniAPI.forEach(item => {
                if (item.message) {
                    omniRow.push(this.runValueTextBlack('Omni Channels are not enabled in ' + this.currentAccount.Name + ' org.'));
                } else {
                    omniRow.push(this.runValueTextBlack('Omni Channels are enabled in ' + this.currentAccount.Name + ' org.'));
                }
            });
        }

        let importAPI = null;
        if (typeof this.externalData['ImportExport'] != 'undefined') {
            importAPI = JSON.parse(this.externalData['ImportExport']);
        }
        let importRow = [];
        if (importAPI != null && importAPI.totalSize) {
            importRow.push(this.runValueTextBlack('Scheduled Data Export Process is available in ' + this.currentAccount.Name + ' org.'));
        } else {
            importRow.push(this.runValueTextBlack('No scheduled Data Export Process is available in ' + this.currentAccount.Name + ' org.'));
        }

        let accountTeamsAPI = null;
        if (typeof this.externalData['AccountTeams'] != 'undefined') {
            accountTeamsAPI = JSON.parse(this.externalData['AccountTeams']);
        }
        let accountTeamRow = []

        if (accountTeamsAPI != null && accountTeamsAPI.records && accountTeamsAPI.records.length > 0) {
            accountTeamRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('Account Name'), this.runHeaderRowBlueText('User Name'), this.runHeaderRowBlueText('Role')));
            accountTeamsAPI.records.forEach(i => {
                accountTeamRow.push(this.Row3ColWithValue(i.Account.Name, i.User.Name, i.TeamMemberRole));
            });
        } else {
            accountTeamRow.push(this.Row3ColWithValue('', '',));
        }

        let roleHierarchyAPI = null;
        if (typeof this.externalData['Role Hierarchy'] != 'undefined') {
            roleHierarchyAPI = JSON.parse(this.externalData['Role Hierarchy']);
        }
        let roleHierarchyRow = [];
        if (roleHierarchyAPI != null) {
            roleHierarchyAPI.records.forEach(i => {
                roleHierarchyRow.push(this.generateBullets(i.Name));
            });
        }

        let communitiesAPI = null;
        if (typeof this.externalData['Communities'] != 'undefined') {
            communitiesAPI = JSON.parse(this.externalData['Communities']);
        }
        let communitiesAPIRow = [];
        let communitiesCount = 0;
        if (communitiesAPI != null) {
            communitiesCount = communitiesAPI.totalSize;
            communitiesAPI.records.forEach(i => {
                communitiesAPIRow.push(this.generateBullets(i.Name));
            });
        }

        let customAppAPI = null;
        if (typeof this.externalData['CustomAPP'] != 'undefined') {
            customAppAPI = JSON.parse(this.externalData['CustomAPP']);
        }
        let customAPPRow = [];
        if (customAppAPI != null) {
            customAppAPI.records.forEach(i => {
                customAPPRow.push(this.Row3ColWithValue(i.Label, i.Description, ''));
            });
        }
        let priceBookAPI = null;
        if (typeof this.externalData['Price Book'] != 'undefined') {
            priceBookAPI = JSON.parse(this.externalData['Price Book']);
        }
        let priceBookRow = [];
        let priceBooxCount = 0;
        if (priceBookAPI != null) {
            priceBooxCount = priceBookAPI.totalSize;
            priceBookAPI.records.forEach(i => {
                priceBookRow.push(this.Row2ColWithValue(i.Pricebook2.Name, i.Product2.Name));
            });
        }
        let pathAPI = null;
        if (typeof this.externalData['Path'] != 'undefined') {
            pathAPI = JSON.parse(this.externalData['Path']);
        }
        let pathRow = [];
        if (pathAPI != null) {
            pathAPI.records.forEach(i => {
                if (i.RecordType) {
                    pathRow.push(this.Row2ColWithValue(i.MasterLabel, i.SobjectType + ' - ' + i.RecordType.Name));
                } else {
                    pathRow.push(this.Row2ColWithValue(i.MasterLabel, i.SobjectType));
                }
            });
        }

        let flowApi = null;
        if (typeof this.externalData['Flow'] != 'undefined') {
            flowApi = JSON.parse(this.externalData['Flow']);
        }
        let flowApiRow = [];
        let flowCount = 0;
        if (flowApi != null) {
            flowCount = flowApi.totalSize;
            flowApi.records.forEach(i => {
                flowApiRow.push(this.Row2ColWithValue(i.ApiName, i.ProcessType));
            });
        }
        let permissionSetApi = null;
        if (typeof this.externalData['Permission Set'] != 'undefined') {
            permissionSetApi = JSON.parse(this.externalData['Permission Set']);
        }
        let permissionSetRow = [];
        if (permissionSetApi != null) {
            permissionSetApi.records.forEach(i => {
                if (i.License) {
                    permissionSetRow.push(this.Row3ColWithValue(i.Name, i.Description, i.License.Name));
                } else {
                    permissionSetRow.push(this.Row3ColWithValue(i.Name, i.Description, ''));
                }
            });
        }

        let reportAPI = null;
        if (typeof this.externalData['Report'] != 'undefined') {
            reportAPI = JSON.parse(this.externalData['Report']);
        }
        let reportRow = [];
        let reportCount = 0;
        if (reportAPI != null) {
            reportCount = reportAPI.totalSize;
            reportAPI.records.forEach(i => {
                reportRow.push(this.Row3ColWithValue(i.DeveloperName, i.Description, ''));
            });
        }
        let emailFolderAPI = null;
        if (typeof this.externalData['Email Folder'] != 'undefined') {
            emailFolderAPI = JSON.parse(this.externalData['Email Folder']);
        }
        let emailFolderRow = [];
        const folderNameToCountMap = {};
        if (emailFolderAPI != null) {
            emailFolderAPI.records.forEach(record => {
                const folderName = record.FolderName;
                if (folderNameToCountMap[folderName]) {
                    folderNameToCountMap[folderName]++;
                } else {
                    folderNameToCountMap[folderName] = 1;
                }
            });
            for (let folderName in folderNameToCountMap) {
                emailFolderRow.push(this.Row2ColWithValue(folderName, folderNameToCountMap[folderName]));
            }
        }
        let queueAPI = null;
        if (typeof this.externalData['Queue'] != 'undefined') {
            queueAPI = JSON.parse(this.externalData['Queue']);
        }
        let queueRow = [];
        if (queueAPI != null) {
            queueAPI.records.forEach(i => {
                queueRow.push(this.Row3ColWithValue(i.Queue.Name, i.SobjectType, ''));
            });
        }
        let scheduledJobAPI = null;
        if (typeof this.externalData['ScheduledJob'] != 'undefined') {
            scheduledJobAPI = JSON.parse(this.externalData['ScheduledJob']);
        }
        let scheduledJobRow = [];
        let schediledJobCount = 0;
        if (scheduledJobAPI != null) {
            schediledJobCount = scheduledJobAPI.totalSize;
            scheduledJobAPI.records.forEach(i => {
                scheduledJobRow.push(this.Row2ColWithValue(i.CronJobDetail.Name, i.State));
            });
        }

        let auraAPI = null;
        if (typeof this.externalData['Aura'] != 'undefined') {
            auraAPI = JSON.parse(this.externalData['Aura']);
        }
        let auraRow = [];
        let auraCount = 0
        if (auraAPI != null) {
            auraCount = auraAPI.totalSize;
            auraAPI.records.forEach(i => {
                auraRow.push(this.Row1ColWithValue(i.DeveloperName));
            });
        }
        let visualforcePageAPi = null;
        if (typeof this.externalData['Apex Pages'] != 'undefined') {
            visualforcePageAPi = JSON.parse(this.externalData['Apex Pages']);
        }
        let apexComponentAPI = null;
        if (typeof this.externalData['Aura'] != 'undefined') {
            apexComponentAPI = JSON.parse(this.externalData['Apex Component']);
        }
        let vfPageCount = 0;
        if (visualforcePageAPi != null) {
            vfPageCount = visualforcePageAPi.totalSize;
        }
        let vfComponentCount = 0;
        if (apexComponentAPI != null) {
            vfComponentCount = apexComponentAPI.totalSize;
        }

        let AppExchangeAPI = null;
        if (typeof this.externalData['AppExchange'] != 'undefined') {
            AppExchangeAPI = JSON.parse(this.externalData['AppExchange']);
        }

        let appExchangeRow = [];
        let appExchangeCount = 0;
        if (AppExchangeAPI != null) {
            appExchangeCount = AppExchangeAPI.totalSize;
            AppExchangeAPI.records.forEach(i => {
                appExchangeRow.push(this.Row3ColWithValue(i.SubscriberPackage.Name, i.SubscriberPackage.NamespacePrefix, i.SubscriberPackage.Description));
            });
        }
        let workFlowRuleAPI = null;
        if (typeof this.externalData['Work Flow Rules'] != 'undefined') {
            workFlowRuleAPI = JSON.parse(this.externalData['Work Flow Rules']);
        }
        let apexTriggerAPI = null;
        if (typeof this.externalData['Apex Trigger'] != 'undefined') {
            apexTriggerAPI = JSON.parse(this.externalData['Apex Trigger']);
        }
        let approvalProcessAPI = null;
        if (typeof this.externalData['Approval Process'] != 'undefined') {
            approvalProcessAPI = JSON.parse(this.externalData['Approval Process']);
        }
        let QueueAPI = null;
        if (typeof this.externalData['Queue'] != 'undefined') {
            QueueAPI = JSON.parse(this.externalData['Queue']);
        }
        let combinedRecords = [];

        if (workFlowRuleAPI != null) {
            combinedRecords = combinedRecords.concat(workFlowRuleAPI.records);
        }
        if (apexTriggerAPI != null) {
            combinedRecords = combinedRecords.concat(apexTriggerAPI.records);
        }
        if (approvalProcessAPI != null) {
            combinedRecords = combinedRecords.concat(approvalProcessAPI.records);
        }
        if (QueueAPI != null) {
            combinedRecords = combinedRecords.concat(QueueAPI.records);
        }
        let counts = {};

        combinedRecords.forEach(record => {
            let tableEnumOrId = record.TableEnumOrId;
            let recordType = record.attributes.type;

            if (counts[tableEnumOrId]) {
                if (recordType === 'WorkflowRule') {
                    counts[tableEnumOrId]['WorkFlow count']++;
                }
                if (recordType == 'ApexTrigger') {
                    counts[tableEnumOrId]['Apex trigger count']++;
                }
                if (recordType == 'ProcessDefinition') {
                    counts[tableEnumOrId]['Approval count']++;
                }
                if (recordType == 'QueueSobject') {
                    counts[tableEnumOrId]['Approval count']++;
                }
            } else {
                counts[tableEnumOrId] = {
                    tableEnumOrId,
                    'WorkFlow count': recordType === 'WorkflowRule' ? 1 : 0,
                    'Apex trigger count': recordType === 'ApexTrigger' ? 1 : 0,
                    'Approval count': recordType === 'ProcessDefinition' ? 1 : 0,
                    'Queue count': recordType === 'QueueSobject' ? 1 : 0
                };
            }
        });
        let countsArray = Object.values(counts);

        let totalWorkFlowCount = 0;
        let totalApexTriggerCount = 0;
        let totalApprovalCount = 0;
        let totalQueueCount = 0;
        let processRow = [];
        for (let count of countsArray) {
            totalWorkFlowCount += count['WorkFlow count'];
            totalApexTriggerCount += count['Apex trigger count'];
            totalApprovalCount += count['Approval count'];
            totalQueueCount += count['Queue count'];
            processRow.push(this.Row6ColWithValue(count.tableEnumOrId, count['WorkFlow count'], 0, count['Apex trigger count'], count['Approval count'], count['Queue count']));
        }
        processRow.push(this.Row6ColWithValue('TOTAL', totalWorkFlowCount, 0, totalApexTriggerCount, totalApprovalCount, totalQueueCount));

        let siteAPI = null;
        if (typeof this.externalData['Site'] != 'undefined') {
            siteAPI = JSON.parse(this.externalData['Site']);
        }
        let domainAPI = null;
        if (typeof this.externalData['Domain'] != 'undefined') {
            domainAPI = JSON.parse(this.externalData['Domain']);
        }
        let customURLAPI = null;
        if (typeof this.externalData['CustomURLs'] != 'undefined') {
            customURLAPI = JSON.parse(this.externalData['CustomURLs']);
        }


        let sitesRow = [];
        let domainRow = [];
        let customUrlRow = [];
        if (siteAPI != null && siteAPI.records && siteAPI.records.length > 0) {
            sitesRow.push(this.Row2ColWithValue(this.runHeaderRowBlueText('Site Label'), this.runHeaderRowBlueText('Site URL')));
            siteAPI.records.forEach(i => {
                sitesRow.push(this.Row2ColWithValue(i.Site.MasterLabel, i.Domain.Domain));
            });
        } else {
            sitesRow.push(this.Row2ColWithValue('', ''));

        }
        domainRow.push(this.runSideHeading('Domain:'));
        if (domainAPI != null) {
            domainAPI.records.forEach(i => {
                domainRow.push(this.generateBullets(i.Domain));
            });
        }
        customUrlRow.push(this.runSideHeading('Custom URLs:'));
        if (customURLAPI != null) {
            customURLAPI.records.forEach(i => {
                customUrlRow.push(this.generateBullets(i.Domain.Domain));
            });
        }
        let supportProcessAPI = null;
        if (typeof this.externalData['SupportProcess'] != 'undefined') {
            supportProcessAPI = JSON.parse(this.externalData['SupportProcess']);
        }
        let supportProcessRow = []

        if (supportProcessAPI != null && supportProcessAPI != null && supportProcessAPI.records && supportProcessAPI.records.length > 0) {
            supportProcessRow.push(this.Row2ColWithValue(this.runHeaderRowBlueText('Support Process'), this.runHeaderRowBlueText('Case Status')));
            supportProcessAPI.records.forEach(i => {
                supportProcessRow.push(this.Row2ColWithValue(i.Name, 'Active'));
            });
        } else {
            supportProcessRow.push(this.Row2ColWithValue('', ''));
        }

        let leadAssignmentAPI = null;
        if (typeof this.externalData['Lead Assignment Rules'] != 'undefined') {
            leadAssignmentAPI = JSON.parse(this.externalData['Lead Assignment Rules']);
        }
        let leadAssignmentRow = [];
        let leadAsgnCount = 0;
        if (leadAssignmentAPI != null && leadAssignmentAPI.records && leadAssignmentAPI.records.length > 0) {
            leadAsgnCount = leadAssignmentAPI.totalSize;
            leadAssignmentRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('Routing Name'), this.runHeaderRowBlueText('Lead Owner'), this.runHeaderRowBlueText('Email Address')));
            leadAssignmentAPI.records.forEach(i => {
                leadAssignmentRow.push(this.Row3ColWithValue(i.Name, '', ''));
            });
        } else {
            leadAssignmentRow.push(this.Row3ColWithValue('', '', ''));
        }

        let caseAssignmentAPI = null;
        if (typeof this.externalData['Case Assignment Rules'] != 'undefined') {
            caseAssignmentAPI = JSON.parse(this.externalData['Case Assignment Rules']);
        }
        let caseAssignmentRow = [];
        let caseAsgnCount = 0;

        if (caseAssignmentAPI != null && caseAssignmentAPI.records && caseAssignmentAPI.records.length > 0) {
            caseAsgnCount = caseAssignmentAPI.totalSize;
            caseAssignmentRow.push(this.Row3ColWithValue(this.runHeaderRowBlueText('Routing Name'), this.runHeaderRowBlueText('Case Owner'), this.runHeaderRowBlueText('Email Address')));
            caseAssignmentAPI.records.forEach(i => {
                caseAssignmentRow.push(this.Row3ColWithValue(i.Name, '', ''));
            });
        } else {
            caseAssignmentRow.push(this.Row3ColWithValue('', '', ''));
        }

        let caseAutoResponseAPI = null;
        if (typeof this.externalData['Case Auto Response Rules'] != 'undefined') {
            caseAutoResponseAPI = JSON.parse(this.externalData['Case Auto Response Rules']);
        }
        let caseAutoResponseRow = [];
        let leadAutoResponseAPI = null;
        if (typeof this.externalData['Lead Auto Response Rules'] != 'undefined') {
            leadAutoResponseAPI = JSON.parse(this.externalData['Lead Auto Response Rules']);
        }
        let leadAutoResponseRow = [];
        let caseAutoCount = 0;
        let leadAutoCount = 0;
        if (caseAutoResponseAPI != null && caseAutoResponseAPI.records && caseAutoResponseAPI.records.length > 0) {
            caseAutoCount = caseAutoResponseAPI.totalSize;
            caseAutoResponseRow.push(this.Row2ColWithValue(this.runHeaderRowBlueText('Routing Name'), this.runHeaderRowBlueText('Case Owner')));
            caseAutoResponseAPI.records.forEach(i => {
                caseAutoResponseRow.push(this.Row2ColWithValue(i.Name, ''));
            });
        } else {
            caseAutoResponseRow.push(this.Row2ColWithValue('', ''));
        }

        if (leadAutoResponseAPI != null && leadAutoResponseAPI.records && leadAutoResponseAPI.records.length > 0) {
            leadAutoCount = leadAutoResponseAPI.totalSize;
            leadAutoResponseRow.push(this.Row2ColWithValue(this.runHeaderRowBlueText('Routing Name'), this.runHeaderRowBlueText('Lead Owner')));
            leadAutoResponseAPI.records.forEach(i => {
                leadAutoResponseRow.push(this.Row2ColWithValue(i.Name, ''));
            });
        } else {
            leadAutoResponseRow.push(this.Row2ColWithValue('', ''));
        }

        let r = [
            this.generateHeading1('4 KNOWLEDGE TRANSFER'),
            this.generateHeading2('4.1 Salesforce Orgs'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('<List the different Salesforce Orgs being used by the customer and the business case for each of the org>', false, 20, 'Verdana', '7ED7A6', true)
                ],
            }),
            this.generateHeading2('4.2 Business Process '),
            new docx.Paragraph({
                children: [
                    this.runParagraph('<Detail the different business processes currently supported by the Salesforce for the customer. Provide business process diagrams wherever possible>', false, 20, 'Verdana', '7ED7A6', true)
                ],
            }),
            this.generateHeading2('4.3 Architecture Diagram –NA'),
            this.generateHeading2('4.4 Development Process/Methodology'),
            this.generateHeading2('4.5 QA Process'),
            this.generateHeading2('4.6 Release Process'),
            this.generateHeading2('4.7 Permission Sets'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + flowCount + ' permission sets in ' + this.currentAccount.Name + ' org. The permission sets details are listed below.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Permission Set Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3700,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Description')],
                                borders: this._no_border,
                                width: {
                                    size: 3700,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('License')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                        ]
                    }),
                    ...permissionSetRow,

                ]
            }),

            this.generateHeading2('4.8 Role Hierarchy'),
            ...roleHierarchyRow,
            this.generateHeading2('4.9 Salesforce Object Model'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The Salesforce Object Model of the extensively used objects is illustrated under this section.  Also attached PDF version.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.generateHeading2('4.10 Object-wise classification of Workflows, Process Builders, Apex Triggers, Queues, Approval Processes'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Object-wise classification of Workflows, Process Builders, Apex Triggers, Queues, and Approval Processes are tabularized below:', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Object')],
                                borders: this._no_border,
                                width: {
                                    size: 3700,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Number of Workflow Rules')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Process Builders')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Apex Triggers')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Approval Process')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Queues')],
                                borders: this._no_border,
                                width: {
                                    size: 1050,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                        ]
                    }),
                    ...processRow,
                ]
            }),
            this.breakRow(),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The active queues and the number of users available for each of them are listed out.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Queue Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Supported Object')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('No. of Users')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                        ]
                    }),
                    ...queueRow,
                ]
            }),
            this.generateHeading2('4.11 Custom Objects'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The list of custom objects along with their master object and usage are mentioned here.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Custom Object Label')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Master Object')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Usage')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                        ]
                    }),
                    ...customObjectrow,
                ]
            }),
            this.generateHeading2('4.12 Omni-Channels'),
            ...omniRow,
            this.generateHeading2('4.13 Email Templates'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The number of active email templates categorized based on folders are listed below:', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Folder Name')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('No. of email templates')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...emailFolderRow,
                ]
            }),
            this.generateHeading2('4.14 Price Books and Products '),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + priceBooxCount + ' active products under this price book. Please find the list of ' + priceBookAPI.totalSize + ' active products below.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Price Book Name')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Product')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...priceBookRow,
                ]
            }),
            this.generateHeading2('4.15 Flows'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + flowApi.totalSize + ' flows in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Flow Label')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Type')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...flowApiRow,
                ]
            }),
            this.generateHeading2('4.16 Apex Classes, Test Classes & Code Coverage '),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + apexCount + ' apex classes in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Apex Class')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Code Coverage')],
                                borders: this._no_border,
                                width: {
                                    size: 1500,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...apexclassRow,
                ]
            }),
            this.generateHeading2('4.17 Renamed Standard Tabs and Labels  '),
            this.generateHeading2('4.18 Visualforce Pages and Visualforce Components '),
            new docx.Paragraph({ children: [this.runParagraph(vfPageCount + ' Visual pages and ' + vfComponentCount + ' Visualforce Components are there in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.generateHeading2('4.19 Paths'),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Path Name')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Object – Record Type')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...pathRow,
                ]
            }),
            this.breakRow(),
            this.generateHeading2('4.20 Web-to-Leads and Web-to-Case'),
            this.generateHeading2('4.21 Email-to-Case'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Names of routings and the case owner and email address that it is assigned to, is mentioned here.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Routing Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Case Owner')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Email Address')],
                                borders: this._no_border,
                                width: {
                                    size: 3166,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                        ]
                    }),
                    this.emptyRow3Col(),
                    this.emptyRow3Col(),
                    this.emptyRow3Col(),
                ]
            }),
            this.generateHeading2('4.22 Lead Assignment Rule and Case Assignment Rule'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('There are ' + leadAsgnCount + ' lead assignment rules and ' + caseAsgnCount + '  case assignment rules in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({


                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...leadAssignmentRow,
                ]
            }),

            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...caseAssignmentRow,
                ]
            }),
            this.generateHeading2('4.23 Case Auto-Response Rules'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + caseAutoCount + ' active Case Auto-Response Rules ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)] }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...caseAutoResponseRow,
                ]
            }),
            this.generateHeading2('4.24 Lead Auto-Response Rules'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + leadAutoCount + ' active Lead Auto-Response Rules ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)] }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...leadAutoResponseRow,
                ]
            }),
            this.generateHeading2('4.25 Sales Process'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The active sales processes and its respective opportunity record types are tabularized.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Sales Process')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Opportunity Record Type')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Usage')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Stage')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            })
                        ]
                    }),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                ]
            }),
            this.generateHeading2('4.26 Support Process'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The active support processes and its respective case record types are stated below.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...supportProcessRow,
                ]
            }),
            this.generateHeading2('4.27 Lead Process'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('The active lead processes and its respective lead record types are tabularized below.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Lead Process')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Lead Record Type')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Usage')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Lead Status')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            })
                        ]
                    }),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                    this.emptyRow4Col(),
                ]
            }),
            this.generateHeading2('4.28 Communities (Experienced Cloud)'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('There are ' + communitiesCount + ' active communities used by ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            ...communitiesAPIRow,
            this.generateHeading2('4.29 Custom Reports'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + reportCount + ' custom reports in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Custom Report Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3500,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Description')],
                                borders: this._no_border,
                                width: {
                                    size: 3500,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Report Type Category')],
                                borders: this._no_border,
                                width: {
                                    size: 2375,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...reportRow,
                ]
            }),
            this.generateHeading2('4.30 Sites, Domains and Custom URLs'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + siteAPI.totalSize + ' sites in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...sitesRow,
                ]
            }),
            this.breakRow(),
            ...domainRow,
            this.breakRow(),
            ...customUrlRow,
            this.generateHeading2('4.31 Scheduled Jobs'),
            this.breakRow(),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + schediledJobCount + ' active scheduled jobs in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Job Name')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('State')],
                                borders: this._no_border,
                                width: {
                                    size: 4750,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...scheduledJobRow,
                ]
            }),
            this.generateHeading2('4.32 Idea Zone'),

            this.generateHeading2('4.33 Integration'),

            this.generateHeading2('4.34 Data Import/Export Processes'),
            this.breakRow(),
            ...importRow,
            this.generateHeading2('4.35 Lightning Resources (Events, Components, Controller, Helper, Design, Style)'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + auraCount + ' lightning resources in ' + this.currentAccount.Name + ' org.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 5000,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Lightning Resources Name')],
                                borders: this._no_border,
                                width: {
                                    size: 5000,
                                    type: docx.WidthType.DXA,
                                },
                            })
                        ]
                    }),
                    ...auraRow,
                ]
            }),
            this.generateHeading2('4.36 AppExchange Apps'),
            new docx.Paragraph({ children: [this.runParagraph('There are ' + appExchangeCount + ' appexchange apps in ' + this.currentAccount.Name + ' org. The app name, the corresponding installed package and its usage is mentioned as shown in the table below.', false, 22, 'Calibri', '002060', false)], }),
            this.breakRow(),
            new docx.Table({
                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('App Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Installed Package ')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Description')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...appExchangeRow,
                ]
            }),
            this.generateHeading2('4.37 Custom Apps'),
            new docx.Paragraph({
                children: [
                    this.runParagraph('Custom Apps that are configured and used are mentioned as shown in the list below.', false, 22, 'Calibri', '002060', false)
                ],
            }),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('App Name')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Usage Purpose ')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowBlueText('Included Tabs ')],
                                borders: this._no_border,
                                width: {
                                    size: 3167,
                                    type: docx.WidthType.DXA,
                                },
                            }),

                        ]
                    }),
                    ...customAPPRow,
                ]
            }),
            this.generateHeading3('4.37.1 Sales'),
            this.generateHeading3('4.37.2 Sales Console'),
            this.generateHeading3('4.37.3 Service Console'),
            this.generateHeading3('4.37.4 Standard Nav Layout'),
            this.generateHeading3('4.37.5 Strategic Account Planning Lightning'),
            this.generateHeading2('4.38 Forecasting'),
            this.generateHeading2('4.39 Account Teams'),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    ...accountTeamRow,
                ]
            }),
            this.breakRow(),


        ];
        return r;
    }
    generateSection5() {
        let r = [
            this.generateHeading1('5 ENGAGEMENT PROCESS'),
            this.generateHeading2('5.1 Weekly Status Report'),
            this.generateHeading2('5.2 Weekly Timesheet | Initiatives'),
            this.generateHeading2('5.3 Monthly Review Meeting'),
        ];
        return r;
    }

    generateSection6() {
        let r = [
            this.generateHeading1('6 OBSERVATIONS & RECOMMENDATIONS'),
            this.generateHeading2('6.1 Unused Salesforce User Licenses – Observation & Recommendations'),
            this.generateHeading2('6.2 Lightning Paths – Recommendation'),
            this.generateHeading2('6.3 Unassigned Permission Sets with Salesforce License Usage – Observation & Recommendation'),
            this.generateHeading2('6.4 Avoid Assigning Users to Multi Permission Sets instead assign to Single Permission Set Group– Observation & Recommendation'),
            this.generateHeading2('6.5 Retirement of Workflow Rules and Process Builders'),
            this.generateHeading2('6.6 Critical Updates'),
            this.generateHeading2('6.7 Security Review'),
            this.generateHeading2('6.8 Lightning Migration'),
        ];
        return r;
    }
    generateSection7() {
        let r = [
            this.generateHeading1('7 REFERENCE DOCUMENTS'),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Document', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Publishing Organization', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Location', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            })
                        ]
                    }),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),
                    this.emptyRow3ColGrey(),]
            }),
        ];
        return r;

    }
    generateSection8() {
        let a = [
            this.generateHeading1('8 GLOSSARY'),
            this.generateHeading2('8.1 Terms and Acronyms'),
            this.breakRow(),
            new docx.Table({

                width: {
                    size: 9500,
                    type: docx.WidthType.DXA,
                },
                rows: [
                    new docx.TableRow({
                        cantSplit: true,
                        children: [
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Terms', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            }),
                            new docx.TableCell({
                                children: [this.runHeaderRowWhiteText('Definitions', 18)],
                                borders: this._no_border,
                                shading: {
                                    fill: "808080",
                                    type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE,
                                    color: "FFFFFF",
                                },
                            })
                        ]
                    }),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                    this.emptyRow2ColGrey(),
                ]
            }),
        ];
        return a;

    }

    generateSection9() {
        let a = [
            this.generateHeading1('9 ADDENDUM'),
            this.generateHeading2('9.1 Einstein Sales Readiness Assessor Report'),
            this.generateHeading2('9.2 Optimizer Report'),
        ];
        return a;
    }
    generateHeading1(text) {
        return new docx.Paragraph({
            border: this.headingSectionBorder,
            shading: { type: docx.ShadingType.REVERSE_DIAGONAL_STRIPE, color: "D9D9D9", fill: "D9D9D9" },
            children: [new docx.TextRun({ text: text, bold: true, size: 28, font: 'Times New Roman', color: '0000FF' })],
            heading: docx.HeadingLevel.HEADING_1,
        });
    }
    generateHeading2(text) {
        return new docx.Paragraph({
            children: [
                new docx.TextRun({ text: text, bold: true, size: 24, font: { name: "Arial" }, color: '800000', break: 1 })
            ],
            heading: docx.HeadingLevel.HEADING_2,
        });
    }
    generateHeading3(textString) {
        return new docx.Paragraph({
            children: [
                new docx.TextRun({ text: textString, bold: true, size: 24, font: { name: "Arial" }, color: '800000', break: 1 })
            ],
            heading: docx.HeadingLevel.HEADING_3,
        });
    }
    breakRow() {
        return new docx.Paragraph('');
    }
    runParagraph(textString, bold, size, fontName, color, italics) {
        return new docx.TextRun({ text: textString, bold: bold, size: size, font: { name: fontName }, color: color, italics: italics, });
    }
    emptyRow2ColGrey() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 50, after: 50 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });
    }
    emptyRow3ColGrey() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 50, after: 50 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });
    }
    emptyRow4ColGrey() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 50, after: 50 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });
    }
    emptyRow2Col() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 40, after: 40 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });
    }
    emptyRow3Col() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 40, after: 40 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });
    }
    emptyRow4Col() {
        const paragraph = new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 40, after: 40 } });
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border }), new docx.TableCell({ children: [paragraph], borders: this._no_border })] });

    }
    Row1ColWithValue(str1) {
        return new docx.TableRow({ children: [new docx.TableCell({ children: [this.runValueTextBlack(str1)], borders: this._no_border })] });
    }
    runHeaderRowBlackText(textString) {
        return new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 35, after: 35 }, alignment: docx.AlignmentType.CENTER, children: [this.generateTextRun(textString)] })
    }
    runHeaderRowBlueText(textString) {
        return new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 35, after: 35 }, alignment: docx.AlignmentType.CENTER, children: [this.generateTableHeaderText(textString)] })
    }
    runSideHeading(textString) {
        return new docx.Paragraph({ alignment: docx.AlignmentType.LEFT, children: [this.generateTableHeaderText(textString)] })
    }
    runHeaderRowWhiteText(textString, size) {
        return new docx.Paragraph({ indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 35, after: 35 }, alignment: docx.AlignmentType.CENTER, children: [this.generateTextRunWhite(textString, size)] })
    }
    runValueText(textString) {
        return new docx.Paragraph({
            children: [
                this.runParagraph(textString, false, 22, 'Calibri', '002060', false),
            ],
            alignment: docx.AlignmentType.JUSTIFIED,
        })
    }
    runValueTextBlack(textString) {
        return new docx.Paragraph({
            children: [
                this.runParagraph(textString, false, 22, 'Calibri', '000000', false),
            ],
            alignment: docx.AlignmentType.LEFT,
            indent: { left: 100, right: 100, top: 100, bottom: 100 }, spacing: { before: 50, after: 50 }
        })
    }
    Row2ColWithValue(str1, str2) {
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [this.runValueTextBlack(str1)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str2)], borders: this._no_border })] });
    }
    Row3ColWithValue(str1, str2, str3) {
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [this.runValueTextBlack(str1)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str2)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str3)], borders: this._no_border })] });
    }
    Row6ColWithValue(str1, str2, str3, str4, str5, str6) {
        return new docx.TableRow({ cantSplit: true, children: [new docx.TableCell({ children: [this.runValueTextBlack(str1)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str2)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str3)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str4)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str5)], borders: this._no_border }), new docx.TableCell({ children: [this.runValueTextBlack(str6)], borders: this._no_border })] });
    }
    generateBullets(txt) {
        return new docx.Paragraph({
            children: [
                this.runParagraph(txt, false, 22, 'Calibri', '000000', false),
            ],
            alignment: docx.AlignmentType.LEFT,
            bullet: { level: 0 }
        })
    }
    generateTextRun(cellString) {
        let textRun = new docx.TextRun({ text: cellString, bold: true, size: 18, font: { name: "Verdana" } });
        return textRun;
    }
    generateTextRunWhite(cellString, fontSize) {
        let textRun = new docx.TextRun({ text: cellString, bold: true, size: fontSize, font: { name: "Verdana" }, color: 'FFFFFF' });
        return textRun;
    }
    generateTableHeaderText(cellString) {
        let textRun = new docx.TextRun({ text: cellString, bold: true, size: 18, font: { name: "Verdana" }, color: '002060' });
        return textRun;
    }
    headerContent() {

        const logoDB = docx.Media.addImage(this.document, this.dbLogo, 210, 48);
        return new docx.Header({
            children: [
                new docx.Paragraph({
                    border: {
                        bottom: {
                            color: "365F91",
                            space: 2,
                            value: "single",
                            size: 5,
                        }
                    },
                    children: [
                        new docx.Run({ inline: true, children: [logoDB] }),
                        new docx.Run({ inline: true, children: [new docx.TextRun({ text: '\t\t\t\t\t        Onboarding Template', bold: false, size: 18, font: { name: "Verdana" } })] })
                    ]
                })
            ],
        })
    }
    footerContent() {
        return new docx.Footer({
            children: [

                new docx.Paragraph({
                    border: {
                        top: {
                            color: "365F91",
                            space: 2,
                            value: "single",
                            size: 5,
                        }
                    },
                    alignment: docx.AlignmentType.LEFT,
                    children: [
                        new docx.TextRun({
                            text: '<Proj_Code>On Boarding', bold: false, size: 18, font: { name: "Verdana" }
                        }),
                        new docx.TextRun({
                            text: '\t\t\tTemplate / V1.0', bold: false, size: 18, font: { name: "Verdana" }
                        }),
                        new docx.TextRun({
                            children: ['\t\t\t'],
                        }),
                        new docx.TextRun({
                            children: ["Page ", docx.PageNumber.CURRENT],
                        }),
                        new docx.TextRun({
                            children: [" of ", docx.PageNumber.TOTAL_PAGES],
                        }),
                    ],
                }),
            ],
        })
    }
}