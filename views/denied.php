<?php
/**
 * Copyright (C) 2014 - 2017 Threenity CMS - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary  and confidential
 * Written by : nicelife90 <yanicklafontaine@gmail.com>
 * Last edit : 2018
 *
 *
 */

require $_SERVER['DOCUMENT_ROOT'] . '/views/partials/header.php';

use ThreenityCMS\Helpers\Path;

?>
    <div class="content-wrapper">
        <section class="content-header">
            <h1 id="module" class="hidden">Access denied</h1>
            <ol class="breadcrumb hidden">
                <li><a href="<?php echo Path::module(); ?>/denied.php"><i class="fa fa-dashboard"></i>Access denied</a>
                </li>

            </ol>
        </section>

        <!-- Main content -->
        <section class="content container-fluid">

            <div class="row">
                <div class="col-md-12">
                    <div class="box box-danger">
                        <div class="box-body">
                            <div class="row">
                                <div class="col-md-12">
                                    <img style="margin: 0 auto;" class="img-responsive"
                                         src="<?php echo Path::img(); ?>/denied.png">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


        </section>
        <!-- /.content -->
    </div>
<?php
require $_SERVER['DOCUMENT_ROOT'] . '/views/partials/footer.php';